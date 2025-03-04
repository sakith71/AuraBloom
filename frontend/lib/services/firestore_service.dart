// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Delete user profile - useful for account deletion
  Future<void> deleteUserProfile(String uid) async {
    try {
      await users.doc(uid).delete();
      print('User profile deleted: $uid');
    } catch (e) {
      print('Error deleting user profile: $e');
      throw Exception('Failed to delete user profile: $e');
    }
  }

  // Update specific user fields without replacing the entire document
  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) async {
    try {
      // Add timestamp
      fields['updatedAt'] = DateTime.now().toIso8601String();

      await users.doc(uid).update(fields);
      print('User fields updated: $uid, Fields: ${fields.keys.join(', ')}');
    } catch (e) {
      print('Error updating user fields: $e');
      throw Exception('Failed to update user fields: $e');
    }
  }

  // Batch update multiple users - useful for admin functions
  Future<void> batchUpdateUsers(
    List<String> userIds,
    Map<String, dynamic> updates,
  ) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final timestamp = DateTime.now().toIso8601String();
      updates['updatedAt'] = timestamp;

      for (String uid in userIds) {
        DocumentReference userRef = users.doc(uid);
        batch.update(userRef, updates);
      }

      await batch.commit();
      print('Batch update completed for ${userIds.length} users');
    } catch (e) {
      print('Error in batch update: $e');
      throw Exception('Failed to perform batch update: $e');
    }
  }
}
