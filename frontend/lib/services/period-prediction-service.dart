import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class PeriodPredictionService {
  
  // Use 10.0.2.2 instead of 127.0.0.1 when running on Android emulator
  // For physical devices or iOS simulator, you might need the actual IP address of your computer
  String get _apiBaseUrl {
    // Check if running on Android emulator
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000'; // Special IP for Android emulator to access host
    } else {
      return 'http://127.0.0.1:8000'; // For iOS simulator or actual devices
    }
  }
  
  // Make a direct prediction with specific parameters
  Future<double> makePrediction({
    required double meanCycleLength,
    required double lengthOfMenses,
    required double meanMensesLength,
    required double bmi
  }) async {
    try {
      try {
        final response = await http.post(
          Uri.parse('${_apiBaseUrl}/predict'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'MeanCycleLength': meanCycleLength,
            'LengthofMenses': lengthOfMenses,
            'MeanMensesLength': meanMensesLength,
            'BMI': bmi
          }),
        ).timeout(const Duration(seconds: 10)); // Add timeout
        
        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          return result['prediction'];
        } else {
          // If API fails, return a simple prediction based on mean cycle length
          return meanCycleLength;
        }
      } catch (e) {
        // If API fails, return a simple prediction based on mean cycle length
        return meanCycleLength;
      }
    } catch (e) {
      throw Exception('Error in prediction service: $e');
    }
  }
}