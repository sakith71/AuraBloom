import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/models/notification.dart';

// Mock Timestamp for testing
class MockTimestamp extends Timestamp {
  MockTimestamp(int seconds, int nanoseconds) : super(seconds, nanoseconds);
}

void main() {
  group('NotificationType', () {
    test('should have correct number of values', () {
      expect(NotificationType.values.length, 7);
    });

    test('should have all expected values', () {
      expect(
        NotificationType.values,
        containsAll([
          NotificationType.like,
          NotificationType.comment,
          NotificationType.reply,
          NotificationType.healthTip,
          NotificationType.periodReminder,
          NotificationType.cycleUpdate,
          NotificationType.appUpdate,
        ]),
      );
    });
  });

  group('UserNotification', () {
    // Test constructor
    group('constructor', () {
      test('should create a UserNotification with required properties', () {
        final now = DateTime.now();
        final notification = UserNotification(
          id: '123',
          userId: 'user456',
          triggerUserId: 'trigger789',
          triggerUserName: 'Jane Doe',
          type: NotificationType.like,
          createdAt: now,
        );

        expect(notification.id, '123');
        expect(notification.userId, 'user456');
        expect(notification.triggerUserId, 'trigger789');
        expect(notification.triggerUserName, 'Jane Doe');
        expect(notification.triggerUserAvatar, null);
        expect(notification.postId, null);
        expect(notification.commentId, null);
        expect(notification.replyId, null);
        expect(notification.content, null);
        expect(notification.type, NotificationType.like);
        expect(notification.createdAt, now);
        expect(notification.isRead, false); // Default value
      });

      test('should create a UserNotification with all properties', () {
        final now = DateTime.now();
        final notification = UserNotification(
          id: '123',
          userId: 'user456',
          triggerUserId: 'trigger789',
          triggerUserName: 'Jane Doe',
          triggerUserAvatar: 'avatar.jpg',
          postId: 'post123',
          commentId: 'comment456',
          replyId: 'reply789',
          content: 'This is a notification content',
          type: NotificationType.comment,
          createdAt: now,
          isRead: true,
        );

        expect(notification.id, '123');
        expect(notification.userId, 'user456');
        expect(notification.triggerUserId, 'trigger789');
        expect(notification.triggerUserName, 'Jane Doe');
        expect(notification.triggerUserAvatar, 'avatar.jpg');
        expect(notification.postId, 'post123');
        expect(notification.commentId, 'comment456');
        expect(notification.replyId, 'reply789');
        expect(notification.content, 'This is a notification content');
        expect(notification.type, NotificationType.comment);
        expect(notification.createdAt, now);
        expect(notification.isRead, true);
      });
    });

    // Test fromMap method
    group('fromMap', () {
      test('should create a UserNotification from a complete map', () {
        final now = DateTime.now();
        final map = {
          'id': '123',
          'userId': 'user456',
          'triggerUserId': 'trigger789',
          'triggerUserName': 'Jane Doe',
          'triggerUserAvatar': 'avatar.jpg',
          'postId': 'post123',
          'commentId': 'comment456',
          'replyId': 'reply789',
          'content': 'This is a notification content',
          'type': 'comment',
          'createdAt': now,
          'isRead': true,
        };

        final notification = UserNotification.fromMap(map);

        expect(notification.id, '123');
        expect(notification.userId, 'user456');
        expect(notification.triggerUserId, 'trigger789');
        expect(notification.triggerUserName, 'Jane Doe');
        expect(notification.triggerUserAvatar, 'avatar.jpg');
        expect(notification.postId, 'post123');
        expect(notification.commentId, 'comment456');
        expect(notification.replyId, 'reply789');
        expect(notification.content, 'This is a notification content');
        expect(notification.type, NotificationType.comment);
        expect(notification.createdAt, now);
        expect(notification.isRead, true);
      });

      test('should handle missing fields with default values', () {
        final map = {'id': '123'};

        final notification = UserNotification.fromMap(map);

        expect(notification.id, '123');
        expect(notification.userId, '');
        expect(notification.triggerUserId, '');
        expect(notification.triggerUserName, 'Unknown');
        expect(notification.type, NotificationType.like); // Default type
        expect(notification.isRead, false); // Default value
      });

      test('should handle Timestamp createdAt field', () {
        // Create a timestamp for Jan 1, 2023
        final timestamp = MockTimestamp(1672531200, 0); // Jan 1, 2023
        final expectedDateTime = DateTime(2023, 1, 1);

        final map = {
          'id': '123',
          'userId': 'user456',
          'triggerUserId': 'trigger789',
          'triggerUserName': 'Jane Doe',
          'type': 'like',
          'createdAt': timestamp,
        };

        final notification = UserNotification.fromMap(map);

        // Compare year, month, day to avoid millisecond differences
        expect(notification.createdAt.year, expectedDateTime.year);
        expect(notification.createdAt.month, expectedDateTime.month);
        expect(notification.createdAt.day, expectedDateTime.day);
      });

      test('should handle String createdAt field', () {
        final dateString = '2023-01-01T12:00:00.000';
        final expectedDateTime = DateTime(2023, 1, 1, 12);

        final map = {
          'id': '123',
          'userId': 'user456',
          'triggerUserId': 'trigger789',
          'triggerUserName': 'Jane Doe',
          'type': 'like',
          'createdAt': dateString,
        };

        final notification = UserNotification.fromMap(map);

        expect(notification.createdAt, expectedDateTime);
      });

      test(
        'should handle ServerTimestamp field (_seconds and _nanoseconds)',
        () {
          final serverTimestamp = {
            '_seconds': 1672531200, // Jan 1, 2023
            '_nanoseconds': 0,
          };
          final expectedDateTime = DateTime.fromMicrosecondsSinceEpoch(
            1672531200 * 1000000,
          );

          final map = {
            'id': '123',
            'userId': 'user456',
            'triggerUserId': 'trigger789',
            'triggerUserName': 'Jane Doe',
            'type': 'like',
            'createdAt': serverTimestamp,
          };

          final notification = UserNotification.fromMap(map);

          // Compare year, month, day to avoid millisecond differences
          expect(notification.createdAt.year, expectedDateTime.year);
          expect(notification.createdAt.month, expectedDateTime.month);
          expect(notification.createdAt.day, expectedDateTime.day);
          expect(notification.createdAt.hour, expectedDateTime.hour);
          expect(notification.createdAt.minute, expectedDateTime.minute);
          expect(notification.createdAt.second, expectedDateTime.second);
        },
      );

      test('should handle missing createdAt field', () {
        final map = {
          'id': '123',
          'userId': 'user456',
          'triggerUserId': 'trigger789',
          'triggerUserName': 'Jane Doe',
          'type': 'like',
        };

        final notification = UserNotification.fromMap(map);

        // Should default to current time, just verify it's a DateTime
        expect(notification.createdAt, isA<DateTime>());
      });

      test('should handle invalid type field', () {
        final map = {
          'id': '123',
          'userId': 'user456',
          'triggerUserId': 'trigger789',
          'triggerUserName': 'Jane Doe',
          'type': 'invalidType',
          'createdAt': DateTime.now(),
        };

        final notification = UserNotification.fromMap(map);

        // Should default to 'like' type
        expect(notification.type, NotificationType.like);
      });

      test('should handle null type field', () {
        final map = {
          'id': '123',
          'userId': 'user456',
          'triggerUserId': 'trigger789',
          'triggerUserName': 'Jane Doe',
          'createdAt': DateTime.now(),
        };

        final notification = UserNotification.fromMap(map);

        // Should default to 'like' type
        expect(notification.type, NotificationType.like);
      });

      test(
        'should handle exception in parsing and return fallback notification',
        () {
          // This map will cause an exception in createdAt parsing
          final map = {
            'id': '123',
            'createdAt': {'invalid': 'timestamp format'},
          };

          final notification = UserNotification.fromMap(map);

          // Should return a fallback notification with default values
          expect(notification.id, '123');
          expect(notification.userId, '');
          expect(notification.triggerUserId, '');
          expect(notification.triggerUserName, 'Unknown');
          expect(notification.type, NotificationType.like);
          expect(notification.createdAt, isA<DateTime>());
        },
      );
    });

    // Test toMap method
    group('toMap', () {
      test('should convert UserNotification to a map correctly', () {
        final now = DateTime(2023, 1, 1, 12); // Use fixed date for testing

        final notification = UserNotification(
          id: '123',
          userId: 'user456',
          triggerUserId: 'trigger789',
          triggerUserName: 'Jane Doe',
          triggerUserAvatar: 'avatar.jpg',
          postId: 'post123',
          commentId: 'comment456',
          replyId: 'reply789',
          content: 'This is a notification content',
          type: NotificationType.comment,
          createdAt: now,
          isRead: true,
        );

        final map = notification.toMap();

        expect(map['id'], '123');
        expect(map['userId'], 'user456');
        expect(map['triggerUserId'], 'trigger789');
        expect(map['triggerUserName'], 'Jane Doe');
        expect(map['triggerUserAvatar'], 'avatar.jpg');
        expect(map['postId'], 'post123');
        expect(map['commentId'], 'comment456');
        expect(map['replyId'], 'reply789');
        expect(map['content'], 'This is a notification content');
        expect(map['type'], 'comment'); // Should be just the enum value name
        expect(map['createdAt'], '2023-01-01T12:00:00.000');
        expect(map['isRead'], true);
      });

      test('should convert enum type to string correctly', () {
        final now = DateTime.now();

        // Test all notification types
        for (final type in NotificationType.values) {
          final notification = UserNotification(
            id: '123',
            userId: 'user456',
            triggerUserId: 'trigger789',
            triggerUserName: 'Jane Doe',
            type: type,
            createdAt: now,
          );

          final map = notification.toMap();
          final expectedTypeName = type.toString().split('.').last;

          expect(map['type'], expectedTypeName);
        }
      });
    });

    // Test round-trip conversion (object -> map -> object)
    group('round-trip conversion', () {
      test(
        'should maintain consistency when converting between UserNotification and Map',
        () {
          final now = DateTime(2023, 1, 1, 12); // Use fixed date for testing

          final originalNotification = UserNotification(
            id: '123',
            userId: 'user456',
            triggerUserId: 'trigger789',
            triggerUserName: 'Jane Doe',
            triggerUserAvatar: 'avatar.jpg',
            postId: 'post123',
            commentId: 'comment456',
            replyId: 'reply789',
            content: 'This is a notification content',
            type: NotificationType.comment,
            createdAt: now,
            isRead: true,
          );

          final map = originalNotification.toMap();
          final recreatedNotification = UserNotification.fromMap(map);

          expect(recreatedNotification.id, originalNotification.id);
          expect(recreatedNotification.userId, originalNotification.userId);
          expect(
            recreatedNotification.triggerUserId,
            originalNotification.triggerUserId,
          );
          expect(
            recreatedNotification.triggerUserName,
            originalNotification.triggerUserName,
          );
          expect(
            recreatedNotification.triggerUserAvatar,
            originalNotification.triggerUserAvatar,
          );
          expect(recreatedNotification.postId, originalNotification.postId);
          expect(
            recreatedNotification.commentId,
            originalNotification.commentId,
          );
          expect(recreatedNotification.replyId, originalNotification.replyId);
          expect(recreatedNotification.content, originalNotification.content);
          expect(recreatedNotification.type, originalNotification.type);
          expect(
            recreatedNotification.createdAt,
            originalNotification.createdAt,
          );
          expect(recreatedNotification.isRead, originalNotification.isRead);
        },
      );
    });
  });
}
