import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

class ChatService {
  // Dynamically set the base URL based on platform
  String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080'; // Special IP for Android emulator
    } else if (Platform.isIOS) {
      return 'http://192.168.123.175:8080'; // For iOS simulator
    } else {
      return 'http://192.168.123.175:8080'; // Fallback
    }
  }

  // Simple method to test API connectivity
  Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/ping'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': message}),
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('response')) {
          return jsonResponse['response'];
        } else {
          return jsonResponse
              .toString(); // Fallback in case response format changes
        }
      } else {
        return 'Error: ${response.statusCode} - ${response.reasonPhrase}';
      }
    } catch (e) {
      return 'Network error: $e';
    }
  }
}
