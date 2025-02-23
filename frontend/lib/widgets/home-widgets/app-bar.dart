import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final VoidCallback onProfileTap;

  const CustomAppBar({
    super.key,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'AuraBloom',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // Notifications navigation
                },
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: onProfileTap,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ],
          ),
        ],
      ),
    );
  }
}