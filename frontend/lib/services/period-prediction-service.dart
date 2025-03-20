import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/period-prediction-model.dart';
import '../services/firestore_service.dart';

class PeriodPredictionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Use 10.0.2.2 instead of 127.0.0.1 when running on Android emulator
  // For physical devices or iOS simulator, you might need the actual IP address of your computer
  String get _apiBaseUrl {
    // Check if running on Android emulator
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000'; // Special IP for Android emulator to access host
    } else {
      return 'http://127.0.0.1:8000'; // For iOS simulator or actual devices
    }
  }

  // Get predictions for a user
  Future<Map<String, dynamic>> getPredictionsForUser(String userId) async {
    try {
      // First try to get from the Firestore cache if recent
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Check if we have recent predictions (less than 24 hours old)
        if (userData.containsKey('lastPredictionDate') &&
            userData.containsKey('predictedNextPeriodStart') &&
            userData['lastPredictionDate'] != null &&
            userData['predictedNextPeriodStart'] != null) {
          DateTime lastPrediction = DateTime.parse(
            userData['lastPredictionDate'],
          );
          if (DateTime.now().difference(lastPrediction).inHours < 24) {
            // Return cached prediction
            return {
              'predictedCycleLength': userData['predictedCycleLength'] ?? 28,
              'nextPeriodStartDate': userData['predictedNextPeriodStart'],
              'fromCache': true,
              'lastPredictionDate': userData['lastPredictionDate'],
              'modelType': userData['modelType'] ?? 'Cached Calculation',
            };
          }
        }
      }

      // If no cached prediction exists or it's too old, call the API

      try {
        final response = await http
            .get(Uri.parse('$_apiBaseUrl/predict_for_user/$userId'))
            .timeout(const Duration(seconds: 10)); // Add timeout

        if (response.statusCode == 200) {
          Map<String, dynamic> result = json.decode(response.body);

          // Validate that required fields exist
          if (result['predictedCycleLength'] == null ||
              result['nextPeriodStartDate'] == null) {
            final fallbackResult = _getFallbackPrediction(userDoc);

            // Create fallback prediction model and store in Firestore
            final prediction = PeriodPredictionModel(
              predictedCycleLength: fallbackResult['predictedCycleLength'],
              nextPeriodStartDate: DateTime.parse(
                fallbackResult['nextPeriodStartDate'],
              ),
              lastPredictionDate: DateTime.now(),
              isAiPrediction: false,
              isFallback: true,
              modelType: 'Simple Fallback (Invalid API Response)',
            );

            await _firestoreService.storePredictionData(userId, prediction);

            return {...fallbackResult, 'error': 'API response invalid'};
          }

          // Create prediction model and store in Firestore
          final prediction = PeriodPredictionModel(
            predictedCycleLength: result['predictedCycleLength'],
            nextPeriodStartDate: DateTime.parse(result['nextPeriodStartDate']),
            lastPredictionDate: DateTime.now(),
            isAiPrediction: result['usedActualModel'] == true,
            isFallback: false,
            modelType: result['modelType'] ?? 'API Calculation',
          );

          await _firestoreService.storePredictionData(userId, prediction);

          return {...result, 'fromCache': false};
        } else {
          // If API call fails, fall back to simple prediction
          final fallbackResult = _getFallbackPrediction(userDoc);

          // Create fallback prediction model and store in Firestore
          final prediction = PeriodPredictionModel(
            predictedCycleLength: fallbackResult['predictedCycleLength'],
            nextPeriodStartDate: DateTime.parse(
              fallbackResult['nextPeriodStartDate'],
            ),
            lastPredictionDate: DateTime.now(),
            isAiPrediction: false,
            isFallback: true,
            modelType: 'Simple Fallback (API Error)',
          );

          await _firestoreService.storePredictionData(userId, prediction);

          return fallbackResult;
        }
      } catch (e) {
        // If API call fails, fall back to simple prediction
        final fallbackResult = _getFallbackPrediction(userDoc);

        // Create fallback prediction model and store in Firestore
        final prediction = PeriodPredictionModel(
          predictedCycleLength: fallbackResult['predictedCycleLength'],
          nextPeriodStartDate: DateTime.parse(
            fallbackResult['nextPeriodStartDate'],
          ),
          lastPredictionDate: DateTime.now(),
          isAiPrediction: false,
          isFallback: true,
          modelType: 'Simple Fallback (API Exception)',
        );

        await _firestoreService.storePredictionData(userId, prediction);

        return fallbackResult;
      }
    } catch (e) {
      // Return a valid fallback without throwing an exception
      final now = DateTime.now();
      return {
        'predictedCycleLength': 28,
        'nextPeriodStartDate':
            now.add(const Duration(days: 28)).toIso8601String(),
        'lastPredictionDate': now.toIso8601String(),
        'fromCache': false,
        'isFallback': true,
        'modelType': 'Emergency Fallback',
        'error': e.toString(),
      };
    }
  }

  // Generate a fallback prediction based on user data
  Map<String, dynamic> _getFallbackPrediction(DocumentSnapshot userDoc) {
    final now = DateTime.now();

    if (!userDoc.exists) {
      // Default values if no user data
      return {
        'predictedCycleLength': 28,
        'nextPeriodStartDate':
            now.add(const Duration(days: 28)).toIso8601String(),
        'lastPredictionDate': now.toIso8601String(),
        'fromCache': false,
        'isFallback': true,
        'modelType': 'Default Fallback',
      };
    }

    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    int cycleLength = 28; // Default value

    // Extract cycle length with proper type handling
    if (userData.containsKey('cycleLength') &&
        userData['cycleLength'] != null) {
      if (userData['cycleLength'] is int) {
        cycleLength = userData['cycleLength'];
      } else if (userData['cycleLength'] is String) {
        cycleLength = int.tryParse(userData['cycleLength']) ?? 28;
      } else if (userData['cycleLength'] is double) {
        cycleLength = userData['cycleLength'].round();
      }
    }

    DateTime lastCycleStartDate = now;
    bool hasValidLastCycle = false;

    // Try to extract last cycle start date with null safety
    if (userData.containsKey('lastCycleStartDate') &&
        userData['lastCycleStartDate'] != null) {
      try {
        lastCycleStartDate = DateTime.parse(userData['lastCycleStartDate']);
        hasValidLastCycle = true;
      } catch (e) {
        throw Exception('Error parsing lastCycleStartDate: $e');
      }
    }

    if (!hasValidLastCycle &&
        userData.containsKey('lastPeriodDate') &&
        userData['lastPeriodDate'] != null) {
      try {
        lastCycleStartDate = DateTime.parse(userData['lastPeriodDate']);
        hasValidLastCycle = true;
      } catch (e) {
        throw Exception('Error parsing last period date: $e');
      }
    }

    // Calculate next period date based on cycle length
    DateTime nextPeriodDate = lastCycleStartDate.add(
      Duration(days: cycleLength),
    );

    // If the calculated next period date is in the past, adjust to the future
    if (nextPeriodDate.isBefore(now)) {
      // Calculate how many cycles we need to add to get to the future
      int cyclesToAdd =
          ((now.difference(nextPeriodDate).inDays) / cycleLength).ceil();
      nextPeriodDate = nextPeriodDate.add(
        Duration(days: cycleLength * cyclesToAdd),
      );
    }

    return {
      'predictedCycleLength': cycleLength,
      'nextPeriodStartDate': nextPeriodDate.toIso8601String(),
      'lastPeriodStartDate': lastCycleStartDate.toIso8601String(),
      'lastPredictionDate': now.toIso8601String(),
      'fromCache': false,
      'isFallback': true,
      'modelType': 'Simple Calculation',
    };
  }

  // Update user data after a period
  Future<Map<String, dynamic>> updateAfterPeriod({
    required String userId,
    required DateTime actualPeriodStartDate,
    int? periodLength,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'userId': userId,
        'actualPeriodStartDate': actualPeriodStartDate.toIso8601String(),
      };

      if (periodLength != null) {
        requestData['periodLength'] = periodLength;
      }

      try {
        final response = await http
            .post(
              Uri.parse('$_apiBaseUrl/update_after_period'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode(requestData),
            )
            .timeout(const Duration(seconds: 10)); // Add timeout

        if (response.statusCode == 200) {
          final result = json.decode(response.body);

          // Validate the API response
          if (result['predictedCycleLength'] == null ||
              result['nextPeriodStartDate'] == null) {
            return _updateFirestoreDirectly(
              userId,
              actualPeriodStartDate,
              periodLength,
            );
          }

          // Create prediction model and store in Firestore
          final prediction = PeriodPredictionModel(
            predictedCycleLength: result['predictedCycleLength'],
            nextPeriodStartDate: DateTime.parse(result['nextPeriodStartDate']),
            lastPeriodStartDate:
                result['lastPeriodStartDate'] != null
                    ? DateTime.parse(result['lastPeriodStartDate'])
                    : actualPeriodStartDate,
            lastPredictionDate: DateTime.now(),
            isAiPrediction: result['usedActualModel'] == true,
            isFallback: false,
            modelType: result['modelType'] ?? 'API Update',
          );

          await _firestoreService.storePredictionData(userId, prediction);

          return result;
        } else {
          // If API call fails, update Firestore directly
          return _updateFirestoreDirectly(
            userId,
            actualPeriodStartDate,
            periodLength,
          );
        }
      } catch (e) {
        // If API call fails, update Firestore directly
        return _updateFirestoreDirectly(
          userId,
          actualPeriodStartDate,
          periodLength,
        );
      }
    } catch (e) {
      throw Exception('Error updating period data: $e');
    }
  }

  // Update Firestore directly if API is unavailable
  Future<Map<String, dynamic>> _updateFirestoreDirectly(
    String userId,
    DateTime actualPeriodStartDate,
    int? periodLength,
  ) async {
    try {
      // Get user document
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      Map<String, dynamic> userData = {};

      if (userDoc.exists) {
        userData = userDoc.data() as Map<String, dynamic>;
      }

      // Calculate actual cycle length with null safety
      int actualCycleLength = 28; // Default

      if (userData.containsKey('lastCycleStartDate') &&
          userData['lastCycleStartDate'] != null) {
        try {
          DateTime lastCycleStartDate = DateTime.parse(
            userData['lastCycleStartDate'],
          );
          actualCycleLength =
              actualPeriodStartDate.difference(lastCycleStartDate).inDays;
          if (actualCycleLength <= 0) actualCycleLength = 28;
        } catch (e) {
          // Use default if parsing fails
        }
      }

      // Update data
      Map<String, dynamic> updateData = {
        'lastCycleStartDate': actualPeriodStartDate.toIso8601String(),
        'actualCycleLength': actualCycleLength,
      };

      if (periodLength != null) {
        updateData['periodLength'] = periodLength;
      }

      // Update Firestore
      await _firestore.collection('users').doc(userId).update(updateData);

      // Calculate prediction
      int predictedCycleLength = 28; // Default

      // Extract cycle length with proper type handling
      if (userData.containsKey('cycleLength') &&
          userData['cycleLength'] != null) {
        if (userData['cycleLength'] is int) {
          predictedCycleLength = userData['cycleLength'];
        } else if (userData['cycleLength'] is String) {
          predictedCycleLength = int.tryParse(userData['cycleLength']) ?? 28;
        } else if (userData['cycleLength'] is double) {
          predictedCycleLength = userData['cycleLength'].round();
        }
      } else {
        // If we calculated an actual cycle length and it's reasonable, use it
        if (actualCycleLength >= 21 && actualCycleLength <= 45) {
          predictedCycleLength = actualCycleLength;
        }
      }

      DateTime nextPeriodDate = actualPeriodStartDate.add(
        Duration(days: predictedCycleLength),
      );

      // Create prediction model and store in Firestore
      final prediction = PeriodPredictionModel(
        predictedCycleLength: predictedCycleLength,
        nextPeriodStartDate: nextPeriodDate,
        lastPeriodStartDate: actualPeriodStartDate,
        lastPredictionDate: DateTime.now(),
        isAiPrediction: false,
        isFallback: true,
        modelType: 'Direct Firestore Update',
      );

      await _firestoreService.storePredictionData(userId, prediction);

      return {
        'userId': userId,
        'predictedCycleLength': predictedCycleLength,
        'nextPeriodStartDate': nextPeriodDate.toIso8601String(),
        'lastPeriodStartDate': actualPeriodStartDate.toIso8601String(),
        'lastPredictionDate': DateTime.now().toIso8601String(),
        'isFallback': true,
        'modelType': 'Direct Firestore Update',
      };
    } catch (e) {
      throw Exception('Failed to update data in Firestore: $e');
    }
  }

  // Make a direct prediction with specific parameters
  Future<double> makePrediction({
    required double meanCycleLength,
    required double lengthOfMenses,
    required double meanMensesLength,
    required double bmi,
  }) async {
    try {
      try {
        final response = await http
            .post(
              Uri.parse('${_apiBaseUrl}/predict'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'MeanCycleLength': meanCycleLength,
                'LengthofMenses': lengthOfMenses,
                'MeanMensesLength': meanMensesLength,
                'BMI': bmi,
              }),
            )
            .timeout(const Duration(seconds: 10)); // Add timeout

        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          if (result.containsKey('prediction') &&
              result['prediction'] != null) {
            return double.parse(result['prediction'].toString());
          } else {
            return meanCycleLength;
          }
        } else {
          // If API fails, return a simple prediction based on mean cycle length
          return meanCycleLength;
        }
      } catch (e) {
        // If API fails, return a simple prediction based on mean cycle length
        return meanCycleLength;
      }
    } catch (e) {
      throw Exception('Error in prediction service: $e');
    }
  }
}
