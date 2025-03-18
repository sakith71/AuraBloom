import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  static Future<String> getResponse(String userMessage) async {
    const apiUrl = 'http://192.168.8.101:5000/chat';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'message': userMessage}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['reply'];
      } else {
        return 'Sorry, something went wrong. Please try again.';
      }
    } catch (e) {
      return 'Failed to connect to the server. Please check your connection.';
    }
  }
}
