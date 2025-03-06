import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user-model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection references
  final CollectionReference users = FirebaseFirestore.instance.collection('users');
  
  // Create or update user profile
  Future<void> saveUserProfile(UserModel user) async {
    try {
      await users.doc(user.uid).set(user.toMap());
    } catch (e) {
      print('Error saving user: $e');
      rethrow;
    }
  }
  
  // Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await users.doc(uid).get();
      
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      rethrow;
    }
  }
  
  // Save period data
  Future<void> savePeriodData(String uid, DateTime periodStartDate) async {
    try {
      await _firestore.collection('users').doc(uid).collection('periods').add({
        'periodStartDate': periodStartDate.toIso8601String(),
        'loggedAt': DateTime.now().toIso8601String(),
      });
      
      // Also update the lastPeriodDate in the user document
      await users.doc(uid).update({
        'lastPeriodDate': periodStartDate.toIso8601String(),
      });
    } catch (e) {
      print('Error saving period data: $e');
      rethrow;
    }
  }
  
  // Save symptom entry
  Future<void> saveSymptomEntry(
    String uid, 
    DateTime date, 
    List<String> symptoms, 
    int painLevel,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).collection('symptoms').add({
        'date': date.toIso8601String(),
        'symptoms': symptoms,
        'painLevel': painLevel,
        'loggedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving symptom entry: $e');
      rethrow;
    }
  }
}