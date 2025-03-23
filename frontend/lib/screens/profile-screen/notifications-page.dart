import 'package:flutter/material.dart';
import 'package:frontend/services/notification-service.dart';
import 'package:frontend/services/simplified-health-tips-service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();
  final HealthTipsService _healthTipsService = HealthTipsService();
  bool _periodReminders = true;
  bool _cycleUpdates = true;
  bool _healthTips = true;
  bool _communityUpdates = false;
  bool _appUpdates = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _initializeHealthTipsService(); // Call without await
  }

  // Separate async method
  Future<void> _initializeHealthTipsService() async {
    await _healthTipsService.initialize();
  }

  Future<void> _loadPreferences() async {
    setState(() {
      _isLoading = true;
    });

    final periodReminders =
        await _notificationService.isPeriodRemindersEnabled();
    final cycleUpdates = await _notificationService.isCycleUpdatesEnabled();
    final healthTips = await _notificationService.isHealthTipsEnabled();
    final communityUpdates =
        await _notificationService.isCommunityNotificationsEnabled();
    final appUpdates = await _notificationService.isAppUpdatesEnabled();

    if (mounted) {
      setState(() {
        _periodReminders = periodReminders;
        _cycleUpdates = cycleUpdates;
        _healthTips = healthTips;
        _communityUpdates = communityUpdates;
        _appUpdates = appUpdates;
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePreference(String type, bool value) async {
    switch (type) {
      case 'period':
        await _notificationService.setPeriodRemindersEnabled(value);
        setState(() {
          _periodReminders = value;
        });
        break;
      case 'cycle':
        await _notificationService.setCycleUpdatesEnabled(value);
        setState(() {
          _cycleUpdates = value;
        });
        break;
      case 'health':
        await _notificationService.setHealthTipsEnabled(value);
        setState(() {
          _healthTips = value;
        });
        // Send an immediate health tip if enabled
        if (value) {
          await _healthTipsService.sendHealthTip();
        }
        break;
      case 'community':
        await _notificationService.setCommunityNotificationsEnabled(value);
        setState(() {
          _communityUpdates = value;
        });
        break;
      case 'app':
        await _notificationService.setAppUpdatesEnabled(value);
        setState(() {
          _appUpdates = value;
        });
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? 'Notifications enabled' : 'Notifications disabled',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                decoration: const BoxDecoration(
                  color: Color(
                    0xFFFCF0F7,
                  ), // Using the same background color as PrivacyPage
                ),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildNotificationSection(
                      title: 'Period Reminders',
                      subtitle: 'Get notified about your upcoming period',
                      value: _periodReminders,
                      onChanged: (value) => _updatePreference('period', value),
                    ),
                    const SizedBox(height: 15),
                    _buildNotificationSection(
                      title: 'Cycle Updates',
                      subtitle: 'Receive updates about your cycle phases',
                      value: _cycleUpdates,
                      onChanged: (value) => _updatePreference('cycle', value),
                    ),
                    const SizedBox(height: 15),
                    _buildNotificationSection(
                      title: 'Health Tips',
                      subtitle: 'Get daily health and wellness tips',
                      value: _healthTips,
                      onChanged: (value) => _updatePreference('health', value),
                    ),
                    const SizedBox(height: 15),
                    _buildNotificationSection(
                      title: 'Community Updates',
                      subtitle:
                          'Stay updated with community posts and discussions',
                      value: _communityUpdates,
                      onChanged:
                          (value) => _updatePreference('community', value),
                    ),
                    const SizedBox(height: 15),
                    _buildNotificationSection(
                      title: 'App Updates',
                      subtitle:
                          'Get notified about new features and improvements',
                      value: _appUpdates,
                      onChanged: (value) => _updatePreference('app', value),
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
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color.fromARGB(255, 255, 115, 166),
          ),
        ],
      ),
    );
  }
}
