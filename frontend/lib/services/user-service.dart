import '../services/firestore_service.dart';

class UserService {
  final FirestoreService _firestoreService = FirestoreService();

  // Get just the username for a user
  Future<String> getUserName(String userId) async {
    try {
      print('UserService: Getting username for user $userId');
      final username = await _firestoreService.getUserName(userId);
      print('UserService: Got username: $username');
      return username;
    } catch (e) {
      print('UserService: Error getting username: $e');
      return 'User'; // Default fallback
    }
  }

  // Save the username for a user
  Future<bool> saveUserName(String userId, String username) async {
    try {
      print('UserService: Saving username for user $userId');
      await _firestoreService.saveUserName(userId, username);
      return true;
    } catch (e) {
      print('UserService: Error saving username: $e');
      return false;
    }
  }
}
