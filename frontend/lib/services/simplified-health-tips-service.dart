import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:frontend/models/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/services/notification-service.dart';

class HealthTipsService {
  static const String LAST_TIP_INDEX_KEY = "last_tip_index";
  static const String LAST_TIP_DATE_KEY = "last_tip_date";
  static const String NOTIFICATION_HOUR_KEY = "health_tip_hour";
  static const String NOTIFICATION_MINUTE_KEY = "health_tip_minute";
  static const int DEFAULT_HOUR = 12; // 12 AM by default
  static const int DEFAULT_MINUTE = 0; // 0 minutes by default

  final NotificationService _notificationService = NotificationService();
  final Random _random = Random();

  // Initialize the service
  Future<void> initialize() async {
    if (kDebugMode) {
      print('Initializing Health Tips Service');
    }

    // Check if we should send a tip today
    await _checkAndSendDailyTip();
  }

  // Check if current time is within notification time window
  Future<bool> _isNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(NOTIFICATION_HOUR_KEY) ?? DEFAULT_HOUR;
    final minute = prefs.getInt(NOTIFICATION_MINUTE_KEY) ?? DEFAULT_MINUTE;

    final now = DateTime.now();

    // Check if it's within 15 minutes of the preferred time
    if (now.hour == hour) {
      if (now.minute >= minute && now.minute < minute + 15) {
        return true;
      }
    }

    return false;
  }

  // Check if we should send a tip today and send if needed
  Future<void> _checkAndSendDailyTip() async {
    try {
      // Check if health tips are enabled
      final tipsEnabled = await _notificationService.isHealthTipsEnabled();
      if (!tipsEnabled) {
        if (kDebugMode) {
          print('Health tips are disabled');
        }
        return;
      }

      // Check if we already sent a tip today
      final prefs = await SharedPreferences.getInstance();
      final lastTipDate = prefs.getString(LAST_TIP_DATE_KEY);
      final today = DateTime.now().toIso8601String().split('T')[0];

      if (lastTipDate != today) {
        // Check if it's the right time to send the notification
        if (await _isNotificationTime()) {
          if (kDebugMode) {
            print('It\'s notification time, sending health tip');
          }

          // Send a tip and update the last tip date
          await sendHealthTip();
          await prefs.setString(LAST_TIP_DATE_KEY, today);
        } else {
          if (kDebugMode) {
            print('Not notification time yet. Will check again later.');
          }
        }
      } else {
        if (kDebugMode) {
          print('Already sent a health tip today');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking and sending daily tip: $e');
      }
    }
  }

  // Send a health tip
  Future<void> sendHealthTip() async {
    try {
      // Check if health tips are enabled
      final tipsEnabled = await _notificationService.isHealthTipsEnabled();
      if (!tipsEnabled) {
        if (kDebugMode) {
          print('Health tips are disabled');
        }
        return;
      }

      // Get a random tip
      final tip = await _getRandomHealthTip();

      if (kDebugMode) {
        print('Sending health tip: $tip');
      }

      // Create a notification using your existing notification service
      final user = _notificationService.currentUser;
      if (user != null) {
        await _notificationService.createNotification(
          userId: user.uid,
          postId: 'health_tip_${DateTime.now().millisecondsSinceEpoch}',
          type: NotificationType.like,
          content: tip,
          skipForSelf: false, // Allow self-notifications
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending health tip: $e');
      }
    }
  }

  // Get a random health tip
  Future<String> _getRandomHealthTip() async {
    // Get the last tip index
    final prefs = await SharedPreferences.getInstance();
    final lastTipIndex = prefs.getInt(LAST_TIP_INDEX_KEY) ?? -1;

    // Generate a new index that's different from the last one
    int randomIndex = lastTipIndex;
    while (randomIndex == lastTipIndex) {
      randomIndex = _random.nextInt(_healthTips.length);
    }

    // Save the current index
    await prefs.setInt(LAST_TIP_INDEX_KEY, randomIndex);

    // Return the selected tip
    return _healthTips[randomIndex];
  }

  // Set the notification time
  Future<void> setNotificationTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(NOTIFICATION_HOUR_KEY, hour);
    await prefs.setInt(NOTIFICATION_MINUTE_KEY, minute);

    if (kDebugMode) {
      print('Health tip notification time set to $hour:$minute');
    }
  }

  // Get the current notification time
  Future<Map<String, int>> getNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(NOTIFICATION_HOUR_KEY) ?? DEFAULT_HOUR;
    final minute = prefs.getInt(NOTIFICATION_MINUTE_KEY) ?? DEFAULT_MINUTE;

    return {'hour': hour, 'minute': minute};
  }

  // Force send a health tip now (for testing)
  Future<void> sendImmediateHealthTip() async {
    await sendHealthTip();
  }

  // List of health tips
  static final List<String> _healthTips = [
    'Stay hydrated! Aim to drink 8 glasses of water a day.',
    'Track your period to better understand your cycle patterns.',
    'Practice deep breathing for 5 minutes to reduce stress.',
    'Remember to take your supplements or medications today.',
    'Getting 7-9 hours of sleep can improve your mood and energy levels.',
    'Consider trying yoga or gentle stretching to ease menstrual cramps.',
    'A warm bath with Epsom salts can help relieve period discomfort.',
    'Regular exercise can help regulate your menstrual cycle.',
    'Eating foods rich in iron helps prevent anemia, especially during your period.',
    'Track your mood changes to recognize patterns throughout your cycle.',
    'Calcium-rich foods can help reduce PMS symptoms.',
    'Heat therapy, like a heating pad, can ease menstrual cramps.',
    'Consider switching to organic or eco-friendly menstrual products.',
    'Vitamin D helps with hormone balance and mood regulation.',
    'Magnesium-rich foods can help reduce menstrual pain and mood swings.',
    'Mindfulness meditation can help manage premenstrual anxiety.',
    'Wearing comfortable, loose clothing can help during bloating days.',
    'Ginger tea can help with nausea and inflammation during your period.',
    'Regular sex or masturbation may help reduce menstrual cramps.',
    'Tracking your basal body temperature can help identify your fertility window.',
    'Maintaining a healthy weight can help regulate your menstrual cycle.',
    'Self-care is essential! Schedule time for activities you enjoy.',
    'Herbal teas like chamomile or raspberry leaf may help with period symptoms.',
    'Regular checkups with your gynecologist are important for reproductive health.',
    'Dark chocolate (70%+ cocoa) can help reduce PMS symptoms.',
    'Avoiding caffeine around your period can reduce breast tenderness and anxiety.',
    'Acupuncture may help with menstrual pain and cycle regulation.',
    'A diet rich in whole foods and low in processed foods can improve cycle health.',
    'Practicing good posture can reduce the severity of menstrual back pain.',
    'Essential oils like lavender and clary sage may help with menstrual symptoms.',
  ];
}
