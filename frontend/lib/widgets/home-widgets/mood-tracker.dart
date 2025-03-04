import 'package:flutter/material.dart';

class MoodTracker extends StatelessWidget {
  const MoodTracker({super.key});

  Widget _buildMoodOption(String emoji, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 30)),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
            'Today\'s Mood',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMoodOption('😊', 'Happy'),
              _buildMoodOption('😌', 'Calm'),
              _buildMoodOption('😔', 'Sad'),
              _buildMoodOption('😤', 'Angry'),
              _buildMoodOption('😴', 'Tired'),
            ],
          ),
        ],
      ),
    );
  }
}