import 'package:flutter/material.dart';

class HealthTipsScreen extends StatelessWidget {
  const HealthTipsScreen({super.key});

  Widget _buildTipCard({
    required IconData icon, 
    required String title,
    required Color cardColor,
    required Color iconColor,
  }) {
    return Container(
      width: 110,
      height: 110,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon, 
            color: iconColor, 
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF0F7),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: Colors.pink[300],
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Health Tips',
              style: TextStyle(
                color: Colors.pink[300],
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {
              // Notification functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black87),
            onPressed: () {
              // Profile functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Horizontal row of tip cards
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTipCard(
                    icon: Icons.bolt,
                    title: 'Stay\nActive',
                    cardColor: const Color(0xFFFFE6F1),
                    iconColor: Colors.orange,
                  ),
                  _buildTipCard(
                    icon: Icons.restaurant,
                    title: 'Hydrate &\nEat Well',
                    cardColor: const Color(0xFFE6EEFF),
                    iconColor: Colors.blue[700]!,
                  ),
                  _buildTipCard(
                    icon: Icons.hot_tub,
                    title: 'Apply\nHeat',
                    cardColor: const Color(0xFFE5F8FF),
                    iconColor: Colors.red,
                  ),
                  _buildTipCard(
                    icon: Icons.hotel,
                    title: 'Get\nRest',
                    cardColor: const Color(0xFFE6FFE6),
                    iconColor: Colors.purple,
                  ),
                  _buildTipCard(
                    icon: Icons.spa,
                    title: 'Practice\nMindfulness',
                    cardColor: const Color(0xFFFFF0E6),
                    iconColor: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Additional content could go here
          ],
        ),
      ),
    );
  }
}