import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  final Function(int) onItemTapped;

  const QuickActions({
    super.key,
    required this.onItemTapped,
  });

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildActionButton(
              icon: Icons.calendar_today,
              label: 'Log Period',
              color: Colors.blue,
              onTap: () => onItemTapped(2), // Navigate to Calendar page
            ),
            _buildActionButton(
              icon: Icons.mood,
              label: 'Track Mood',
              color: Colors.purple,
              onTap: () {},
            ),
            _buildActionButton(
              icon: Icons.medical_services_outlined,
              label: 'Symptoms',
              color: Colors.pink,
              onTap: () => onItemTapped(1), // Navigate to Management page
            ),
          ],
        ),
      ],
    );
  }
}