import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/period-prediction-model.dart';
import '../models/user-model.dart';

class FirestoreService {
  // Collection references
  final CollectionReference users = FirebaseFirestore.instance.collection(
    'users',
  );

  // Create or update user profile with error handling and transaction support
  Future<void> saveUserProfile(UserModel user) async {
    try {
      // Use a transaction to ensure data integrity
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentReference userDocRef = users.doc(user.uid);

        // Check if document exists
        DocumentSnapshot userDoc = await transaction.get(userDocRef);

        // Get current timestamp
        final now = DateTime.now().toIso8601String();

        if (userDoc.exists) {
          // Update existing user
          Map<String, dynamic> userData = user.toMap();
          userData['updatedAt'] = now;
          transaction.update(userDocRef, userData);
        } else {
          // Create new user
          Map<String, dynamic> userData = user.toMap();
          userData['createdAt'] = now;
          userData['updatedAt'] = now;
          transaction.set(userDocRef, userData);
        }
      });

      print('User profile saved successfully: ${user.uid}');
    } catch (e) {
      print('Error saving user profile: $e');
      // Re-throw to allow handling in UI
      throw Exception('Failed to save user profile: $e');
    }
  }

  // Get user profile with improved error handling
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await users.doc(uid).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        print('Retrieved user profile: $uid');
        return UserModel.fromMap(data);
      }

      print('User profile not found: $uid');
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      throw Exception('Failed to retrieve user profile: $e');
    }
  }

  // Save just the username
  Future<void> saveUserName(String uid, String username) async {
    try {
      print('FirestoreService: Saving username "$username" for user $uid');
      await users.doc(uid).set({
        'name': username,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      print('Username saved successfully for user: $uid');
    } catch (e) {
      print('Error saving username: $e');
      throw Exception('Failed to save username: $e');
    }
  }

  // Get just the username for a user
  Future<String> getUserName(String uid) async {
    try {
      print('FirestoreService: Getting username for user $uid');
      DocumentSnapshot doc = await users.doc(uid).get();
      print('FirestoreService: Doc exists? ${doc.exists}');

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        print('FirestoreService: Doc data: $data');

        if (data.containsKey('name') &&
            data['name'] != null &&
            data['name'].toString().isNotEmpty) {
          print('FirestoreService: Found username: ${data['name']}');
          return data['name'] as String;
        }
      }
      print('FirestoreService: Username not found, returning default');
      return 'User'; // Default if name not found
    } catch (e) {
      print('FirestoreService: Error getting username: $e');
      return 'User'; // Default on error
    }
  }

  // Update period dates for a user
  Future<void> updatePeriodDates(String uid, Set<String> dates) async {
    try {
      await users.doc(uid).update({'periodDates': dates.toList()});
    } catch (e) {
      print('Error updating period dates: $e');
      throw Exception('Failed to update period dates: $e');
    }
  }

  // Get period dates for a user
  Future<Set<String>> getPeriodDates(String uid) async {
    try {
      DocumentSnapshot doc = await users.doc(uid).get();
      if (doc.exists &&
          (doc.data() as Map<String, dynamic>).containsKey('periodDates')) {
        List<dynamic> datesList =
            (doc.data() as Map<String, dynamic>)['periodDates'];
        return datesList.map((e) => e.toString()).toSet();
      }
      return <String>{};
    } catch (e) {
      print('Error getting period dates: $e');
      return <String>{};
    }
  }

  // Update any user data
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      // Add timestamp
      data['updatedAt'] = DateTime.now().toIso8601String();

      await users.doc(uid).update(data);
    } catch (e) {
      print('Error updating user data: $e');
      throw Exception('Failed to update user data: $e');
    }
  }

  // Store period prediction data using model class
  Future<void> storePredictionData(
    String uid,
    PeriodPredictionModel prediction,
  ) async {
    try {
      final now = DateTime.now();

      // Get user document to check for existing cycle data
      DocumentSnapshot userDoc = await users.doc(uid).get();
      DateTime? lastCycleStartDate;

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        if (userData.containsKey('lastCycleStartDate') &&
            userData['lastCycleStartDate'] != null) {
          try {
            lastCycleStartDate = DateTime.parse(userData['lastCycleStartDate']);
          } catch (e) {
            print('Error parsing existing lastCycleStartDate: $e');
          }
        }
      }

      // Create updated prediction with proper metadata
      final updatedPrediction = prediction.copyWith(
        lastPredictionDate: now,
        lastPeriodStartDate:
            lastCycleStartDate ?? prediction.lastPeriodStartDate,
      );

      // Convert to map and add updatedAt timestamp
      Map<String, dynamic> predictionData = updatedPrediction.toMap();
      predictionData['updatedAt'] = now.toIso8601String();

      await users.doc(uid).update(predictionData);

      // Also store historical prediction in a subcollection for tracking accuracy over time
      await users.doc(uid).collection('predictions').add({
        ...predictionData,
        'createdAt': now.toIso8601String(),
      });

      print(
        'Prediction data stored: $uid, Cycle: ${updatedPrediction.predictedCycleLength}, Next start: ${updatedPrediction.getFormattedNextPeriodDate()}',
      );
    } catch (e) {
      print('Error storing prediction data: $e');
      throw Exception('Failed to store prediction data: $e');
    }
  }

  // Store period prediction data using raw values (for backward compatibility)
  Future<void> storePredictionDataFromValues(
    String uid,
    int predictedCycleLength,
    String nextPeriodStartDate, {
    bool isAiPrediction = false,
    bool isFallback = false,
    String? modelType,
  }) async {
    try {
      // Create a model instance from the provided values
      final prediction = PeriodPredictionModel(
        predictedCycleLength: predictedCycleLength,
        nextPeriodStartDate: DateTime.parse(nextPeriodStartDate),
        lastPredictionDate: DateTime.now(),
        isAiPrediction: isAiPrediction,
        isFallback: isFallback,
        modelType: modelType,
      );

      // Call the model-based method
      await storePredictionData(uid, prediction);
    } catch (e) {
      print('Error storing prediction data from values: $e');
      throw Exception('Failed to store prediction data: $e');
    }
  }
}
