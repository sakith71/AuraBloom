import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class PeriodPredictionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
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
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        
        // Check if we have recent predictions (less than 24 hours old)
        if (userData.containsKey('lastPredictionDate') && 
            userData.containsKey('predictedNextPeriodStart')) {
          
          DateTime lastPrediction = DateTime.parse(userData['lastPredictionDate']);
          if (DateTime.now().difference(lastPrediction).inHours < 24) {
            // Return cached prediction
            return {
              'predictedCycleLength': userData['predictedCycleLength'],
              'nextPeriodStartDate': userData['predictedNextPeriodStart'],
              'fromCache': true
            };
          }
        }
      }
      
      // If no cached prediction exists or it's too old, call the API
      
      try {
        final response = await http.get(
          Uri.parse('${_apiBaseUrl}/predict_for_user/$userId'),
        ).timeout(const Duration(seconds: 10)); // Add timeout
        
        
        if (response.statusCode == 200) {
          Map<String, dynamic> result = json.decode(response.body);
          return {
            ...result,
            'fromCache': false
          };
        } else {
          // If API call fails, fall back to simple prediction
          return _getFallbackPrediction(userDoc);
        }
      } catch (e) {
        // If API call fails, fall back to simple prediction
        return _getFallbackPrediction(userDoc);
      }
    } catch (e) {
      throw Exception('Error in prediction service: $e');
    }
  }
  
  // Generate a fallback prediction based on user data
  Map<String, dynamic> _getFallbackPrediction(DocumentSnapshot userDoc) {
    if (!userDoc.exists) {
      // Default values if no user data
      return {
        'predictedCycleLength': 28,
        'nextPeriodStartDate': DateTime.now().add(const Duration(days: 28)).toIso8601String(),
        'fromCache': false,
        'isFallback': true
      };
    }
    
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    int cycleLength = userData['cycleLength'] ?? 28;
    
    DateTime lastCycleStartDate;
    if (userData.containsKey('lastCycleStartDate') && userData['lastCycleStartDate'] != null) {
      try {
        lastCycleStartDate = DateTime.parse(userData['lastCycleStartDate']);
      } catch (e) {
        lastCycleStartDate = DateTime.now();
      }
    } else if (userData.containsKey('lastCycleStartDate') && userData['lastCycleStartDate'] != null) {
      try {
        lastCycleStartDate = DateTime.parse(userData['lastCycleStartDate']);
      } catch (e) {
        lastCycleStartDate = DateTime.now();
      }
    } else {
      lastCycleStartDate = DateTime.now();
    }
    
    DateTime nextPeriodDate = lastCycleStartDate.add(Duration(days: cycleLength));
    
    return {
      'predictedCycleLength': cycleLength,
      'nextPeriodStartDate': nextPeriodDate.toIso8601String(),
      'lastPeriodStartDate': lastCycleStartDate.toIso8601String(),
      'fromCache': false,
      'isFallback': true
    };
  }
  // Make a direct prediction with specific parameters
  Future<double> makePrediction({
    required double meanCycleLength,
    required double lengthOfMenses,
    required double meanMensesLength,
    required double bmi
  }) async {
    try {
      try {
        final response = await http.post(
          Uri.parse('${_apiBaseUrl}/predict'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'MeanCycleLength': meanCycleLength,
            'LengthofMenses': lengthOfMenses,
            'MeanMensesLength': meanMensesLength,
            'BMI': bmi
          }),
        ).timeout(const Duration(seconds: 10)); // Add timeout
        
        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          return result['prediction'];
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