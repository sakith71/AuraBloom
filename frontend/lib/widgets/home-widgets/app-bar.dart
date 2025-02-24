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
          Row(
            children: [
              Image.asset(
                'assets/logo.png', // Make sure to add your logo image to assets
                height: 30,
                width: 30,
              ),
              const SizedBox(width: 8), // Add spacing between logo and text
              Text(
                'AuraBloom',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 255, 115, 166),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // Notifications navigation
                },
                color: const Color.fromARGB(255, 255, 115, 166),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline),
                onPressed: onProfileTap,
                color: const Color.fromARGB(255, 255, 115, 166),
              ),
            ],
          ),
        ],
      ),
    );
  }
}