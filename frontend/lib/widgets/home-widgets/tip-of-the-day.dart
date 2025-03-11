import 'package:flutter/material.dart';
import 'package:frontend/services/tips-services.dart';
//import '../services/tips-service.dart';

class TipOfTheDay extends StatefulWidget {
  const TipOfTheDay({super.key});

  @override
  State<TipOfTheDay> createState() => _TipOfTheDayState();
}

class _TipOfTheDayState extends State<TipOfTheDay> {
  late String _currentTip;

  @override
  void initState() {
    super.initState();
    // Get a random tip when the widget initializes
    _currentTip = TipsService.getRandomTip();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Did You Know?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentTip,
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
