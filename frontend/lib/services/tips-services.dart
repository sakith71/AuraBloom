import 'dart:math';

class TipsService {
  // List of 50 period-related tips and facts
  static final List<String> _periodTips = [
    "Staying hydrated can help reduce bloating during your period.",
  ];

  // Method to get a random tip
  static String getRandomTip() {
    final random = Random();
    return _periodTips[random.nextInt(_periodTips.length)];
  }

  // Method to get a specific tip (for testing or specific requirements)
  static String getTipByIndex(int index) {
    if (index >= 0 && index < _periodTips.length) {
      return _periodTips[index];
    }
    return getRandomTip(); // Fallback to random if index is out of bounds
  }
}
