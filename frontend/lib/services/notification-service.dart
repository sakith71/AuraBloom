import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/models/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Preference keys
  static const String _prefPeriodReminders = 'pref_period_reminders';
  static const String _prefCycleUpdates = 'pref_cycle_updates';
  static const String _prefHealthTips = 'pref_health_tips';
  static const String _prefCommunityUpdates = 'pref_community_updates';
  static const String _prefAppUpdates = 'pref_app_updates';

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is authenticated and handle auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Create a notification
  Future<void> createNotification({
    required String userId,
    required String? postId,
    String? commentId,
    String? replyId,
    String? content,
    required NotificationType type,
    bool skipForSelf = true,
    String? triggerUserName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      if (kDebugMode) {
        print('Cannot create notification: User not authenticated');
      }
      throw Exception('User not authenticated');
    }

    // Don't create notification if user is notifying themselves
    if (skipForSelf && userId == user.uid) {
      if (kDebugMode) {
        print('Skipping self-notification');
      }
      return;
    }

    // Check if appropriate notifications are enabled based on type
    bool enabled = true;
    switch (type) {
      case NotificationType.like:
      case NotificationType.comment:
      case NotificationType.reply:
        enabled = await isCommunityNotificationsEnabled();
        break;
      case NotificationType.healthTip:
        enabled = await isHealthTipsEnabled();
        break;
      case NotificationType.periodReminder:
        enabled = await isPeriodRemindersEnabled();
        break;
      case NotificationType.cycleUpdate:
        enabled = await isCycleUpdatesEnabled();
        break;
      case NotificationType.appUpdate:
        enabled = await isAppUpdatesEnabled();
        break;
    }

    if (!enabled) {
      if (kDebugMode) {
        print('${type.toString()} notifications are disabled, skipping');
      }
      return;
    }

    try {
      // Get trigger user details
      String effectiveTriggerUserName = triggerUserName ?? '';
      if (effectiveTriggerUserName.isEmpty) {
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          effectiveTriggerUserName = user.displayName!;
        } else if (user.email != null && user.email!.isNotEmpty) {
          effectiveTriggerUserName = user.email!;
        } else {
          effectiveTriggerUserName = 'User_${user.uid.substring(0, 5)}';
        }
      }

      // Truncate content for preview (if provided)
      String? contentPreview;
      if (content != null && content.isNotEmpty) {
        contentPreview =
            content.length > 50 ? '${content.substring(0, 50)}...' : content;
      }

      // Create notification data
      final Map<String, dynamic> notificationData = {
        'userId': userId,
        'triggerUserId': user.uid,
        'triggerUserName': effectiveTriggerUserName,
        'triggerUserAvatar': user.photoURL,
        'postId': postId,
        'commentId': commentId,
        'replyId': replyId,
        'content': contentPreview,
        'type': type.toString().split('.').last,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      if (kDebugMode) {
        print('Creating notification: $notificationData');
      }

      // Add to Firestore
      await _firestore.collection('notifications').add(notificationData);

      if (kDebugMode) {
        print('Notification created successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating notification: $e');
      }
      throw Exception('Failed to create notification: $e');
    }
  }

  // Get notifications for current user with graceful index error handling
  Stream<List<UserNotification>> getNotifications() {
    final user = _auth.currentUser;
    if (user == null) {
      if (kDebugMode) {
        print('Cannot get notifications: User not authenticated');
      }
      // Return empty list instead of throwing an exception
      return Stream.value([]);
    }

    if (kDebugMode) {
      print('Getting notifications for user: ${user.uid}');
    }

    try {
      // First try the query that requires the index
      return _firestore
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .handleError((error) {
            if (kDebugMode) {
              print('Error in notifications stream: $error');

              // Check if it's an index error
              if (error.toString().contains('failed-precondition') &&
                  error.toString().contains('requires an index')) {
                print(
                  'Missing index for notifications query - falling back to simple query',
                );

                // Return a simpler stream when index is missing
                return Stream.value([]);
              }
            }
            // Re-throw if it's not an index error
            throw error;
          })
          .map((snapshot) {
            if (kDebugMode) {
              print(
                'Notifications snapshot received: ${snapshot.docs.length} items',
              );
            }

            return snapshot.docs
                .map((doc) {
                  final data = doc.data();
                  data['id'] = doc.id;

                  try {
                    return UserNotification.fromMap(data);
                  } catch (e) {
                    if (kDebugMode) {
                      print('Error parsing notification: $e');
                      print('Notification data: $data');
                    }
                    // Skip invalid notifications instead of crashing
                    return null;
                  }
                })
                .whereType<UserNotification>()
                .toList(); // Filter out null values
          });
    } catch (e) {
      if (kDebugMode) {
        print('Exception setting up notifications stream: $e');
      }

      // In case of setup error, try a simpler query
      try {
        // Simpler query without ordering (no index required)
        return _firestore
            .collection('notifications')
            .where('userId', isEqualTo: user.uid)
            .snapshots()
            .map((snapshot) {
              final result =
                  snapshot.docs
                      .map((doc) {
                        final data = doc.data();
                        data['id'] = doc.id;

                        try {
                          return UserNotification.fromMap(data);
                        } catch (e) {
                          return null;
                        }
                      })
                      .whereType<UserNotification>()
                      .toList();

              // Sort manually since we can't use orderBy
              result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              return result;
            });
      } catch (fallbackError) {
        // If even the fallback fails, return empty list
        if (kDebugMode) {
          print('Fallback query also failed: $fallbackError');
        }
        return Stream.value([]);
      }
    }
  }

  // Get notifications with index error information
  Future<Map<String, dynamic>> getNotificationsWithIndexInfo() async {
    final user = _auth.currentUser;
    if (user == null) {
      return {
        'success': false,
        'error': 'User not authenticated',
        'needsIndex': false,
        'notifications': <UserNotification>[],
      };
    }

    try {
      // Try to get notifications with the query that needs an index
      final snapshot =
          await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: user.uid)
              .orderBy('createdAt', descending: true)
              .get();

      final notifications =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return UserNotification.fromMap(data);
          }).toList();

      return {
        'success': true,
        'needsIndex': false,
        'notifications': notifications,
      };
    } catch (e) {
      String errorMessage = e.toString();

      // Check if it's an index error
      if (errorMessage.contains('failed-precondition') &&
          errorMessage.contains('requires an index')) {
        // Extract the index creation URL from the error message
        String indexUrl = '';
        final RegExp urlRegex = RegExp(
          r'https:\/\/console\.firebase\.google\.com\/[^\s]+',
        );
        final match = urlRegex.firstMatch(errorMessage);
        if (match != null) {
          indexUrl = match.group(0) ?? '';
        }

        return {
          'success': false,
          'error': errorMessage,
          'needsIndex': true,
          'indexUrl': indexUrl,
          'notifications': <UserNotification>[],
        };
      }

      // Not an index error
      return {
        'success': false,
        'error': errorMessage,
        'needsIndex': false,
        'notifications': <UserNotification>[],
      };
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error marking notification as read: $e');
      }
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (kDebugMode) {
        print('Cannot mark all as read: User not authenticated');
      }
      throw Exception('User not authenticated');
    }

    try {
      // Get unread notifications
      final unreadNotifications =
          await _firestore
              .collection('notifications')
              .where('userId', isEqualTo: user.uid)
              .where('isRead', isEqualTo: false)
              .get();

      if (kDebugMode) {
        print(
          'Found ${unreadNotifications.docs.length} unread notifications to mark as read',
        );
      }

      // Create a batch to update all notifications
      final batch = _firestore.batch();
      for (var doc in unreadNotifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      // Commit the batch update
      await batch.commit();

      if (kDebugMode) {
        print('All notifications marked as read successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error marking all notifications as read: $e');
      }
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();

      if (kDebugMode) {
        print('Notification deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting notification: $e');
      }
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Get unread notification count
  Stream<int> getUnreadCount() {
    final user = _auth.currentUser;
    if (user == null) {
      if (kDebugMode) {
        print('Cannot get unread count: User not authenticated');
      }
      return Stream.value(0);
    }

    try {
      return _firestore
          .collection('notifications')
          .where('userId', isEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((snapshot) {
            final count = snapshot.docs.length;
            if (kDebugMode) {
              print('Unread notifications count: $count');
            }
            return count;
          })
          .handleError((error) {
            if (kDebugMode) {
              print('Error in unread count stream: $error');
            }
            // Return 0 on error instead of crashing
            return 0;
          });
    } catch (e) {
      if (kDebugMode) {
        print('Exception setting up unread count stream: $e');
      }
      // Return 0 on exception
      return Stream.value(0);
    }
  }

  // Notification preferences methods
  Future<void> setNotificationPreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);

    if (kDebugMode) {
      print('Set notification preference $key to $value');
    }
  }

  Future<bool> getNotificationPreference(
    String key, {
    bool defaultValue = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(key) ?? defaultValue;

    if (kDebugMode) {
      print('Get notification preference $key: $value');
    }

    return value;
  }

  // Specific preference setters/getters
  Future<void> setPeriodRemindersEnabled(bool value) async {
    await setNotificationPreference(_prefPeriodReminders, value);
  }

  Future<bool> isPeriodRemindersEnabled() async {
    return getNotificationPreference(_prefPeriodReminders);
  }

  Future<void> setCycleUpdatesEnabled(bool value) async {
    await setNotificationPreference(_prefCycleUpdates, value);
  }

  Future<bool> isCycleUpdatesEnabled() async {
    return getNotificationPreference(_prefCycleUpdates);
  }

  Future<void> setHealthTipsEnabled(bool value) async {
    await setNotificationPreference(_prefHealthTips, value);
  }

  Future<bool> isHealthTipsEnabled() async {
    return getNotificationPreference(_prefHealthTips);
  }

  Future<void> setCommunityNotificationsEnabled(bool value) async {
    await setNotificationPreference(_prefCommunityUpdates, value);
  }

  Future<bool> isCommunityNotificationsEnabled() async {
    return getNotificationPreference(
      _prefCommunityUpdates,
      defaultValue: false,
    );
  }

  Future<void> setAppUpdatesEnabled(bool value) async {
    await setNotificationPreference(_prefAppUpdates, value);
  }

  Future<bool> isAppUpdatesEnabled() async {
    return getNotificationPreference(_prefAppUpdates);
  }
}
