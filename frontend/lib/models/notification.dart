import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum NotificationType { like, comment, reply }

class UserNotification {
  final String id;
  final String userId; // The user who will receive the notification
  final String triggerUserId; // The user who triggered the notification
  final String triggerUserName;
  final String? triggerUserAvatar;
  final String postId;
  final String? commentId;
  final String? replyId;
  final String? content; // Preview of the content that triggered notification
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  UserNotification({
    required this.id,
    required this.userId,
    required this.triggerUserId,
    required this.triggerUserName,
    this.triggerUserAvatar,
    required this.postId,
    this.commentId,
    this.replyId,
    this.content,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  factory UserNotification.fromMap(Map<String, dynamic> map) {
    // Handle notification type parsing safely
    NotificationType parseNotificationType(String? typeStr) {
      if (typeStr == null) return NotificationType.like;

      try {
        return NotificationType.values.firstWhere(
          (e) => e.toString() == 'NotificationType.$typeStr',
          orElse: () => NotificationType.like,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing notification type: $typeStr');
        }
        return NotificationType.like;
      }
    }

    // Handle DateTime parsing safely
    DateTime parseDateTime(dynamic dateValue) {
      if (dateValue == null) {
        return DateTime.now();
      }

      try {
        if (dateValue is DateTime) {
          return dateValue;
        } else if (dateValue is Timestamp) {
          return dateValue.toDate();
        } else if (dateValue is String) {
          return DateTime.parse(dateValue);
        } else if (dateValue is Map<String, dynamic>) {
          // Handle Firestore ServerTimestamp when viewed while pending
          if (dateValue['_seconds'] != null &&
              dateValue['_nanoseconds'] != null) {
            final seconds = dateValue['_seconds'] as int;
            final nanoseconds = dateValue['_nanoseconds'] as int;
            return DateTime.fromMicrosecondsSinceEpoch(
              seconds * 1000000 + (nanoseconds / 1000).round(),
            );
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing date: $dateValue (${dateValue.runtimeType})');
          print('Error details: $e');
        }
      }

      return DateTime.now();
    }

    // Debug the raw map data
    if (kDebugMode) {
      print('Parsing notification: ${map['id']}');
      if (map['createdAt'] != null) {
        print('CreatedAt type: ${map['createdAt'].runtimeType}');
      }
    }

    try {
      final typeStr = map['type'] as String?;

      return UserNotification(
        id: map['id'] ?? '',
        userId: map['userId'] ?? '',
        triggerUserId: map['triggerUserId'] ?? '',
        triggerUserName: map['triggerUserName'] ?? 'Unknown',
        triggerUserAvatar: map['triggerUserAvatar'],
        postId: map['postId'] ?? '',
        commentId: map['commentId'],
        replyId: map['replyId'],
        content: map['content'],
        type: parseNotificationType(typeStr),
        createdAt: parseDateTime(map['createdAt']),
        isRead: map['isRead'] ?? false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating UserNotification from map: $e');
        print('Map data: $map');
      }

      // Return a fallback notification rather than crashing
      return UserNotification(
        id: map['id'] ?? '',
        userId: '',
        triggerUserId: '',
        triggerUserName: 'Unknown',
        postId: '',
        type: NotificationType.like,
        createdAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'triggerUserId': triggerUserId,
      'triggerUserName': triggerUserName,
      'triggerUserAvatar': triggerUserAvatar,
      'postId': postId,
      'commentId': commentId,
      'replyId': replyId,
      'content': content,
      'type': type.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }
}
