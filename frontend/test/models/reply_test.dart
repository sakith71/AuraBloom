import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/models/reply.dart';

void main() {
  group('Reply', () {
    test('should create a Reply instance with required parameters', () {
      final reply = Reply(
        id: 'test-id',
        commentId: 'comment-id',
        authorId: 'author-id',
        authorName: 'John Doe',
        createdAt: DateTime(2023, 1, 1),
        content: 'This is a reply',
      );

      print('Test completed successfully!');

      expect(reply.id, 'test-id');
      expect(reply.commentId, 'comment-id');
      expect(reply.authorId, 'author-id');
      expect(reply.authorName, 'John Doe');
      expect(reply.authorAvatar, '');
      expect(reply.createdAt, DateTime(2023, 1, 1));
      expect(reply.content, 'This is a reply');
      expect(reply.isAnonymous, false);
    });

    test('should create a Reply instance with all parameters', () {
      final reply = Reply(
        id: 'test-id',
        commentId: 'comment-id',
        authorId: 'author-id',
        authorName: 'John Doe',
        authorAvatar: 'avatar-url',
        createdAt: DateTime(2023, 1, 1),
        content: 'This is a reply',
        isAnonymous: true,
      );

      expect(reply.id, 'test-id');
      expect(reply.commentId, 'comment-id');
      expect(reply.authorId, 'author-id');
      expect(reply.authorName, 'John Doe');
      expect(reply.authorAvatar, 'avatar-url');
      expect(reply.createdAt, DateTime(2023, 1, 1));
      expect(reply.content, 'This is a reply');
      expect(reply.isAnonymous, true);
    });

    group('fromMap', () {
      test('should properly parse a complete map', () {
        final map = {
          'id': 'test-id',
          'commentId': 'comment-id',
          'authorId': 'author-id',
          'authorName': 'John Doe',
          'authorAvatar': 'avatar-url',
          'createdAt': '2023-01-01T00:00:00.000',
          'content': 'This is a reply',
          'isAnonymous': true,
        };

        final reply = Reply.fromMap(map);

        expect(reply.id, 'test-id');
        expect(reply.commentId, 'comment-id');
        expect(reply.authorId, 'author-id');
        expect(reply.authorName, 'John Doe');
        expect(reply.authorAvatar, 'avatar-url');
        expect(reply.createdAt, DateTime(2023, 1, 1));
        expect(reply.content, 'This is a reply');
        expect(reply.isAnonymous, true);
      });

      test('should handle missing fields with default values', () {
        final map = {
          'id': 'test-id',
          'commentId': 'comment-id',
          'authorId': 'author-id',
        };

        final reply = Reply.fromMap(map);

        expect(reply.id, 'test-id');
        expect(reply.commentId, 'comment-id');
        expect(reply.authorId, 'author-id');
        expect(reply.authorName, 'Unknown');
        expect(reply.authorAvatar, '');
        expect(reply.content, 'No content');
        expect(reply.isAnonymous, false);
      });

      test('should handle DateTime from Timestamp', () {
        final timestamp = Timestamp.fromDate(DateTime(2023, 1, 1));
        final map = {
          'id': 'test-id',
          'commentId': 'comment-id',
          'authorId': 'author-id',
          'authorName': 'John Doe',
          'createdAt': timestamp,
          'content': 'This is a reply',
        };

        final reply = Reply.fromMap(map);

        expect(reply.createdAt, DateTime(2023, 1, 1));
      });

      test('should handle DateTime from string', () {
        final map = {
          'id': 'test-id',
          'commentId': 'comment-id',
          'authorId': 'author-id',
          'authorName': 'John Doe',
          'createdAt': '2023-01-01T00:00:00.000',
          'content': 'This is a reply',
        };

        final reply = Reply.fromMap(map);

        expect(reply.createdAt, DateTime(2023, 1, 1));
      });

      test('should handle invalid DateTime string', () {
        final map = {
          'id': 'test-id',
          'commentId': 'comment-id',
          'authorId': 'author-id',
          'authorName': 'John Doe',
          'createdAt': 'invalid-date',
          'content': 'This is a reply',
        };

        final reply = Reply.fromMap(map);

        // Should default to DateTime.now(), but we can't test exact equality
        expect(reply.createdAt.year, DateTime.now().year);
      });

      test('should handle missing createdAt field', () {
        final map = {
          'id': 'test-id',
          'commentId': 'comment-id',
          'authorId': 'author-id',
          'authorName': 'John Doe',
          'content': 'This is a reply',
        };

        final reply = Reply.fromMap(map);

        // Should default to DateTime.now(), but we can't test exact equality
        expect(reply.createdAt.year, DateTime.now().year);
      });
    });

    test('toMap should return correct map representation', () {
      final reply = Reply(
        id: 'test-id',
        commentId: 'comment-id',
        authorId: 'author-id',
        authorName: 'John Doe',
        authorAvatar: 'avatar-url',
        createdAt: DateTime(2023, 1, 1),
        content: 'This is a reply',
        isAnonymous: true,
      );

      final map = reply.toMap();

      expect(map['id'], 'test-id');
      expect(map['commentId'], 'comment-id');
      expect(map['authorId'], 'author-id');
      expect(map['authorName'], 'John Doe');
      expect(map['authorAvatar'], 'avatar-url');
      expect(map['createdAt'], '2023-01-01T00:00:00.000');
      expect(map['content'], 'This is a reply');
      expect(map['isAnonymous'], true);
    });
  });
}
