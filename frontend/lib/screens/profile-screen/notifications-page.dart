// lib/screens/profile/pages/notifications_page.dart
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _periodReminders = true;
  bool _cycleUpdates = true;
  bool _healthTips = true;
  bool _communityUpdates = false;
  bool _appUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF4C2CA), // Light Pink
              Color(0xFFD4C0D6), // Light Purple
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildNotificationSection(
              title: 'Period Reminders',
              subtitle: 'Get notified about your upcoming period',
              value: _periodReminders,
              onChanged: (value) {
                setState(() {
                  _periodReminders = value;
                });
              },
            ),
            const SizedBox(height: 15),
            _buildNotificationSection(
              title: 'Cycle Updates',
              subtitle: 'Receive updates about your cycle phases',
              value: _cycleUpdates,
              onChanged: (value) {
                setState(() {
                  _cycleUpdates = value;
                });
              },
            ),
            const SizedBox(height: 15),
            _buildNotificationSection(
              title: 'Health Tips',
              subtitle: 'Get daily health and wellness tips',
              value: _healthTips,
              onChanged: (value) {
                setState(() {
                  _healthTips = value;
                });
              },
            ),
            const SizedBox(height: 15),
            _buildNotificationSection(
              title: 'Community Updates',
              subtitle: 'Stay updated with community posts and discussions',
              value: _communityUpdates,
              onChanged: (value) {
                setState(() {
                  _communityUpdates = value;
                });
              },
            ),
            const SizedBox(height: 15),
            _buildNotificationSection(
              title: 'App Updates',
              subtitle: 'Get notified about new features and improvements',
              value: _appUpdates,
              onChanged: (value) {
                setState(() {
                  _appUpdates = value;
                });
              },
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Note: You can customize your notification preferences at any time.',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}