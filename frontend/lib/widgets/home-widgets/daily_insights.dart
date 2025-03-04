import 'package:flutter/material.dart';

class DailyInsights extends StatelessWidget {
  const DailyInsights({super.key});

  Widget _buildCustomIcon(IconData icon, Color color) {
    return Icon(icon, color: color, size: 28);
  }

  Widget _buildInsightCard({
    required Widget icon,
    required String title,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My daily insights',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInsightCard(
                icon: _buildCustomIcon(Icons.calendar_today, Colors.pink[300]!),
                title: 'Mark period',
                color: const Color(0xFFFAD4E4),
              ),
              const SizedBox(width: 12),
              _buildInsightCard(
                icon: _buildCustomIcon(Icons.add, Colors.blue[300]!),
                title: 'How you feel today',
                color: const Color(0xFFE6E9FF),
              ),
              const SizedBox(width: 12),
              _buildInsightCard(
                icon: _buildCustomIcon(
                  Icons.lightbulb_outline,
                  Colors.pink[300]!,
                ),
                title: 'Health tips',
                color: const Color(0xFFFAD4E4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
