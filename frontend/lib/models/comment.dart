// lib/models/comment.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final DateTime createdAt;
  final String content;
  final bool isAnonymous;
  int replyCount;

  Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar = '',
    required this.createdAt,
    required this.content,
    this.isAnonymous = false,
    this.replyCount = 0,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    DateTime parseDateTime(dynamic dateValue) {
      if (dateValue is DateTime) {
        return dateValue;
      } else if (dateValue is Timestamp) {
        return dateValue.toDate();
      } else if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          print('Error parsing date string: $dateValue');
          return DateTime.now();
        }
      } else {
        print('Unknown date format: $dateValue (${dateValue.runtimeType})');
        return DateTime.now();
      }
    }

    return Comment(
      id: map['id'] ?? '',
      postId: map['postId'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? 'Unknown',
      authorAvatar: map['authorAvatar'] ?? '',
      createdAt: map.containsKey('createdAt') 
          ? parseDateTime(map['createdAt'])
          : DateTime.now(),
      content: map['content'] ?? 'No content',
      isAnonymous: map['isAnonymous'] ?? false,
      replyCount: map['replyCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'createdAt': createdAt.toIso8601String(),
      'content': content,
      'isAnonymous': isAnonymous,
      'replyCount': replyCount,
    };
  }
}