import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/models/comment.dart';

// Mock Timestamp for testing
class MockTimestamp extends Timestamp {
  MockTimestamp(int seconds, int nanoseconds) : super(seconds, nanoseconds);
}

void main() {
  group('Comment', () {
    // Test for the constructor
    test('should create a Comment instance with required properties', () {
      final now = DateTime.now();

      final comment = Comment(
        id: '123',
        postId: 'post456',
        authorId: 'author789',
        authorName: 'Jane Doe',
        createdAt: now,
        content: 'This is a test comment',
      );

      expect(comment.id, '123');
      expect(comment.postId, 'post456');
      expect(comment.authorId, 'author789');
      expect(comment.authorName, 'Jane Doe');
      expect(comment.authorAvatar, ''); // Default value
      expect(comment.createdAt, now);
      expect(comment.content, 'This is a test comment');
      expect(comment.isAnonymous, false); // Default value
      expect(comment.replyCount, 0); // Default value
    });

    // Test for the constructor with all properties specified
    test('should create a Comment instance with all properties specified', () {
      final now = DateTime.now();

      final comment = Comment(
        id: '123',
        postId: 'post456',
        authorId: 'author789',
        authorName: 'Jane Doe',
        authorAvatar: 'avatar.jpg',
        createdAt: now,
        content: 'This is a test comment',
        isAnonymous: true,
        replyCount: 5,
      );

      expect(comment.id, '123');
      expect(comment.postId, 'post456');
      expect(comment.authorId, 'author789');
      expect(comment.authorName, 'Jane Doe');
      expect(comment.authorAvatar, 'avatar.jpg');
      expect(comment.createdAt, now);
      expect(comment.content, 'This is a test comment');
      expect(comment.isAnonymous, true);
      expect(comment.replyCount, 5);
    });

    group('fromMap', () {
      test('should create a Comment from a complete map', () {
        final now = DateTime.now();
        final map = {
          'id': '123',
          'postId': 'post456',
          'authorId': 'author789',
          'authorName': 'Jane Doe',
          'authorAvatar': 'avatar.jpg',
          'createdAt': now,
          'content': 'This is a test comment',
          'isAnonymous': true,
          'replyCount': 5,
        };

        final comment = Comment.fromMap(map);

        expect(comment.id, '123');
        expect(comment.postId, 'post456');
        expect(comment.authorId, 'author789');
        expect(comment.authorName, 'Jane Doe');
        expect(comment.authorAvatar, 'avatar.jpg');
        expect(comment.createdAt, now);
        expect(comment.content, 'This is a test comment');
        expect(comment.isAnonymous, true);
        expect(comment.replyCount, 5);
      });

      test('should handle missing fields with default values', () {
        final map = {'id': '123', 'postId': 'post456', 'authorId': 'author789'};

        final comment = Comment.fromMap(map);

        expect(comment.id, '123');
        expect(comment.postId, 'post456');
        expect(comment.authorId, 'author789');
        expect(comment.authorName, 'Unknown'); // Default value
        expect(comment.authorAvatar, ''); // Default value
        expect(comment.content, 'No content'); // Default value
        expect(comment.isAnonymous, false); // Default value
        expect(comment.replyCount, 0); // Default value
      });

      test('should handle Timestamp createdAt field', () {
        // Create a timestamp for Jan 1, 2023
        final timestamp = MockTimestamp(1672531200, 0); // Jan 1, 2023
        final expectedDateTime = DateTime(2023, 1, 1);

        final map = {
          'id': '123',
          'postId': 'post456',
          'authorId': 'author789',
          'authorName': 'Jane Doe',
          'createdAt': timestamp,
          'content': 'This is a test comment',
        };

        final comment = Comment.fromMap(map);

        // Compare year, month, day to avoid millisecond differences
        expect(comment.createdAt.year, expectedDateTime.year);
        expect(comment.createdAt.month, expectedDateTime.month);
        expect(comment.createdAt.day, expectedDateTime.day);
      });

      test('should handle String createdAt field', () {
        final dateString = '2023-01-01T12:00:00.000';
        final expectedDateTime = DateTime(2023, 1, 1, 12);

        final map = {
          'id': '123',
          'postId': 'post456',
          'authorId': 'author789',
          'authorName': 'Jane Doe',
          'createdAt': dateString,
          'content': 'This is a test comment',
        };

        final comment = Comment.fromMap(map);

        expect(comment.createdAt, expectedDateTime);
      });

      test('should handle invalid String createdAt format', () {
        final map = {
          'id': '123',
          'postId': 'post456',
          'authorId': 'author789',
          'authorName': 'Jane Doe',
          'createdAt': 'invalid-date-format',
          'content': 'This is a test comment',
        };

        final comment = Comment.fromMap(map);

        // Should default to current time, so just verify it's a DateTime
        expect(comment.createdAt, isA<DateTime>());
      });
    });

    group('toMap', () {
      test('should convert Comment to a map correctly', () {
        final now = DateTime(2023, 1, 1, 12); // Use fixed date for testing

        final comment = Comment(
          id: '123',
          postId: 'post456',
          authorId: 'author789',
          authorName: 'Jane Doe',
          authorAvatar: 'avatar.jpg',
          createdAt: now,
          content: 'This is a test comment',
          isAnonymous: true,
          replyCount: 5,
        );

        final map = comment.toMap();

        expect(map['id'], '123');
        expect(map['postId'], 'post456');
        expect(map['authorId'], 'author789');
        expect(map['authorName'], 'Jane Doe');
        expect(map['authorAvatar'], 'avatar.jpg');
        expect(map['createdAt'], '2023-01-01T12:00:00.000');
        expect(map['content'], 'This is a test comment');
        expect(map['isAnonymous'], true);
        expect(map['replyCount'], 5);
      });
    });

    // Test round-trip conversion (toMap -> fromMap)
    test(
      'should maintain consistency when converting between Comment and Map',
      () {
        final now = DateTime(2023, 1, 1, 12); // Use fixed date for testing

        final originalComment = Comment(
          id: '123',
          postId: 'post456',
          authorId: 'author789',
          authorName: 'Jane Doe',
          authorAvatar: 'avatar.jpg',
          createdAt: now,
          content: 'This is a test comment',
          isAnonymous: true,
          replyCount: 5,
        );

        final map = originalComment.toMap();
        final recreatedComment = Comment.fromMap(map);

        expect(recreatedComment.id, originalComment.id);
        expect(recreatedComment.postId, originalComment.postId);
        expect(recreatedComment.authorId, originalComment.authorId);
        expect(recreatedComment.authorName, originalComment.authorName);
        expect(recreatedComment.authorAvatar, originalComment.authorAvatar);
        expect(recreatedComment.createdAt, originalComment.createdAt);
        expect(recreatedComment.content, originalComment.content);
        expect(recreatedComment.isAnonymous, originalComment.isAnonymous);
        expect(recreatedComment.replyCount, originalComment.replyCount);
      },
    );
  });
}
