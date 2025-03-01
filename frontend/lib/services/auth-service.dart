import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Get the current user id
  String? get currentUserId => _auth.currentUser?.uid;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  bool get isUserSignedIn => _auth.currentUser != null;

  // Sign up with email and password
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
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
  ) async {
    // Create initial user model
    UserModel user = UserModel(
      uid: uid,
      name: name,
      age: age,
      height: height,
      weight: weight,
      isRegularPeriod: false, // Default values
      crampsExperience: 'No',
      symptomDuration: '1-3 days',
      additionalSymptoms: [],
    );

    await _firestoreService.saveUserProfile(user);
  }

  // Check if the user has completed onboarding
  Future<bool> hasCompletedOnboarding() async {
    if (currentUserId == null) return false;

    try {
      final userData = await _firestoreService.getUserProfile(currentUserId!);
      // Consider onboarding complete if lastPeriodDate is set
      return userData != null;
    } catch (e) {
      print('Error checking onboarding status: $e');
      return false;
    }
  }
}
