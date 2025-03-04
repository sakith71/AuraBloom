import 'package:flutter/material.dart';

class MyCycles extends StatelessWidget {
  const MyCycles({super.key});

  Widget _buildCycleInfo({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Current cycle section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My cycles',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current cycle',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCycleInfo(
                          icon: Icons.calendar_today,
                          value: '20th day',
                          label: 'Cycle day',
                          iconColor: Colors.pink[300]!,
                        ),
                        _buildCycleInfo(
                          icon: Icons.autorenew,
                          value: '28 Days',
                          label: 'Cycle length',
                          iconColor: Colors.pink[300]!,
                        ),
                        _buildCycleInfo(
                          icon: Icons.favorite,
                          value: '5 Days',
                          label: 'Period length',
                          iconColor: Colors.pink[300]!,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Previous cycle section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Previous cycle length',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 16),
                    _buildCycleInfo(
                      icon: Icons.autorenew,
                      value: '28 Days',
                      label: 'Cycle length',
                      iconColor: Colors.pink[300]!,
                    ),
                    const SizedBox(width: 60),
                    _buildCycleInfo(
                      icon: Icons.favorite,
                      value: '5 Days',
                      label: 'Period length',
                      iconColor: Colors.pink[300]!,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
