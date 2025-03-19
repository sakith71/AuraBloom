import '../services/firestore_service.dart';

class UserService {
  final FirestoreService _firestoreService = FirestoreService();

  // Get just the username for a user
  Future<String> getUserName(String userId) async {
    try {
      final username = await _firestoreService.getUserName(userId);
      return username;
    } catch (e) {
      return 'User'; // Default fallback
    }
  }

  // Save the username for a user
  Future<bool> saveUserName(String userId, String username) async {
    try {
      await _firestoreService.saveUserName(userId, username);
      return true;
    } catch (e) {
      return false;
    }
  }
}
