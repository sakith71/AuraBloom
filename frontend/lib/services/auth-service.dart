import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/user-model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Get the current user id
  String? get currentUserId => _auth.currentUser?.uid;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  bool get isUserSignedIn => _auth.currentUser != null;

  // Check if email already exists
  Future<bool> emailExists(String email) async {
    try {
      // Firebase has no direct method to check if an email exists
      // We'll use fetchSignInMethodsForEmail which returns a list of providers
      // If the list is empty, the email doesn't exist
      final List<String> methods = await _auth.fetchSignInMethodsForEmail(
        email,
      );
      return methods.isNotEmpty;
    } catch (e) {
      print('Error checking email existence: $e');
      return false;
    }
  }

  // Sign up with email and password
  Future<Map<String, dynamic>> signUp(
    String email,
    String password, {
    String? username,
  }) async {
    try {
      // First check if the email already exists
      bool exists = await emailExists(email);
      if (exists) {
        return {
          'success': false,
          'message':
              'This email is already registered. Please sign in or use a different email.',
          'user': null,
        };
      }

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Store the username from the signup form if provided
      if (userCredential.user != null &&
          username != null &&
          username.isNotEmpty) {
        print(
          'Saving username: $username for user: ${userCredential.user!.uid}',
        );
        await _firestoreService.saveUserName(
          userCredential.user!.uid,
          username,
        );
      }

      return {
        'success': true,
        'message': 'Registration successful',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'email-already-in-use') {
        message =
            'This email is already registered. Please sign in or use a different email.';
      } else if (e.code == 'weak-password') {
        message = 'The password is too weak. Please use a stronger password.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else {
        message = e.message ?? 'An error occurred during sign up.';
      }
      return {'success': false, 'message': message, 'user': null};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to sign up: $e',
        'user': null,
      };
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Create user profile in Firestore after registration
  Future<void> createUserProfile(
    String uid,
    String name,
    int age,
    double height,
    double weight,
    double bmi,
  ) async {
    try {
      // Create a temporary user model with just the personal info
      // Other fields will be filled out in subsequent screens
      UserModel userModel = UserModel(
        uid: uid,
        name: name,
        age: age,
        height: height,
        weight: weight,
        bmi: bmi,
        isRegularPeriod: false, // Default values
        crampsExperience: 'No', // These will be updated
        symptomDuration: '1-3 days', // in subsequent screens
        additionalSymptoms: [],
        cycleLength: 28,
        periodLength: 5,
        lastPeriodDate: DateTime.now(),
      );

      // Save to Firestore
      await _firestoreService.saveUserProfile(userModel);
    } catch (e) {
      rethrow; // Re-throw to handle in UI
    }
  }

  // Check if the user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    if (currentUserId == null) return false;

    try {
      final userData = await _firestoreService.getUserProfile(currentUserId!);
      // Consider onboarding complete if lastPeriodDate is set
      return userData != null && userData.lastPeriodDate.year > 2000;
    } catch (e) {
      return false;
    }
  }
}
