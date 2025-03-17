import 'package:flutter/material.dart';
import 'package:frontend/screens/notification-screen.dart';
import 'package:frontend/services/notification-service.dart';

class CustomAppBar extends StatelessWidget {
  final VoidCallback onProfileTap;
  final NotificationService _notificationService = NotificationService();

  CustomAppBar({super.key, required this.onProfileTap});

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
              // Notification button with badge
              StreamBuilder<int>(
                stream: _notificationService.getUnreadCount(),
                builder: (context, snapshot) {
                  final unreadCount = snapshot.data ?? 0;

                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationScreen(),
                            ),
                          );
                        },
                        color: const Color.fromARGB(255, 255, 115, 166),
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              unreadCount > 9 ? '9+' : '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
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
