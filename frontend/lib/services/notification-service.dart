import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/models/notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is authenticated and handle auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Create a notification
  Future<void> createNotification({
    required String userId,
    required String postId,
    String? commentId,
    String? replyId,
    String? content,
    required NotificationType type,
    bool skipForSelf = true,
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

    try {
      // Get trigger user details
      String triggerUserName;
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        triggerUserName = user.displayName!;
      } else if (user.email != null && user.email!.isNotEmpty) {
        triggerUserName = user.email!;
      } else {
        triggerUserName = 'User_${user.uid.substring(0, 5)}';
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
        'triggerUserName': triggerUserName,
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
}
