// lib/utils/user_profile_util.dart
import 'dart:async';
import '../models/user-model.dart';
import '../services/auth-service.dart';
import '../services/firestore_service.dart';

class UserProfileUtil {
  // Singleton pattern
  static final UserProfileUtil _instance = UserProfileUtil._internal();
  factory UserProfileUtil() => _instance;
  UserProfileUtil._internal();

  // Services
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // Stream controller for user profile updates
  final _userProfileController = StreamController<UserModel?>.broadcast();
  Stream<UserModel?> get userProfileStream => _userProfileController.stream;

  // Cached user model
  UserModel? _currentUserModel;
  UserModel? get currentUserModel => _currentUserModel;

  // Initialize and load user data
  Future<void> initialize() async {
    if (_authService.currentUserId != null) {
      await refreshUserProfile();
    }
  }

  // Refresh user profile from Firestore
  Future<UserModel?> refreshUserProfile() async {
    try {
      if (_authService.currentUserId != null) {
        final userData = await _firestoreService.getUserProfile(
          _authService.currentUserId!,
        );
        _currentUserModel = userData;
        _userProfileController.add(userData);
        return userData;
      }
      return null;
    } catch (e) {
      print('Error refreshing user profile: $e');
      return null;
    }
  }

  // Update user profile and notify listeners
  Future<void> updateUserProfile(UserModel updatedUser) async {
    try {
      await _firestoreService.saveUserProfile(updatedUser);
      _currentUserModel = updatedUser;
      _userProfileController.add(updatedUser);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Update specific user fields
  Future<void> updateUserFields(Map<String, dynamic> fields) async {
    try {
      if (_authService.currentUserId != null) {
        await _firestoreService.updateUserFields(
          _authService.currentUserId!,
          fields,
        );
        await refreshUserProfile(); // Refresh to get latest data
      }
    } catch (e) {
      print('Error updating user fields: $e');
      rethrow;
    }
  }

  // Clear cache on logout
  void clearCache() {
    _currentUserModel = null;
    _userProfileController.add(null);
  }

  // Dispose resources
  void dispose() {
    _userProfileController.close();
  }

  // Helper method to create a new user profile
  Future<void> createInitialUserProfile(
    String name,
    int age,
    double height,
    double weight,
  ) async {
    if (_authService.currentUserId != null) {
      final newUser = UserModel(
        uid: _authService.currentUserId!,
        name: name,
        age: age,
        height: height,
        weight: weight,
        isRegularPeriod: false,
        crampsExperience: 'No',
        symptomDuration: '1-3 days',
        additionalSymptoms: [],
        cycleLength: 28,
        periodLength: 5,
        lastPeriodDate: DateTime.now(),
      );

      await updateUserProfile(newUser);
    }
  }
}
