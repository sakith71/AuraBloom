import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/models/community-models.dart';

// Mock Timestamp for testing Firestore timestamps
class MockTimestamp extends Timestamp {
  MockTimestamp(int seconds, int nanoseconds) : super(seconds, nanoseconds);
}

void main() {
  group('CommunityPost', () {
    // Test Constructor
    group('Constructor', () {
      test('should create a CommunityPost with required properties', () {
        final now = DateTime.now();
        final post = CommunityPost(
          id: '123',
          authorId: 'user456',
          authorName: 'Jane Doe',
          createdAt: now,
          content: 'This is a test post',
          tags: ['question', 'health'],
        );

        expect(post.id, '123');
        expect(post.authorId, 'user456');
        expect(post.authorName, 'Jane Doe');
        expect(post.authorAvatar, ''); // Default value
        expect(post.createdAt, now);
        expect(post.content, 'This is a test post');
        expect(post.tags, ['question', 'health']);
        expect(post.likeCount, 0); // Default value
        expect(post.commentCount, 0); // Default value
        expect(post.imageUrls, null); // Default value
        expect(post.isAnonymous, false); // Default value
        expect(post.isPinned, false); // Default value
      });

      test('should create a CommunityPost with all properties', () {
        final now = DateTime.now();
        final post = CommunityPost(
          id: '123',
          authorId: 'user456',
          authorName: 'Jane Doe',
          authorAvatar: 'avatar.jpg',
          createdAt: now,
          content: 'This is a test post with all properties',
          tags: ['question', 'health'],
          likeCount: 10,
          commentCount: 5,
          imageUrls: ['image1.jpg', 'image2.jpg'],
          isAnonymous: true,
          isPinned: true,
        );

        expect(post.id, '123');
        expect(post.authorId, 'user456');
        expect(post.authorName, 'Jane Doe');
        expect(post.authorAvatar, 'avatar.jpg');
        expect(post.createdAt, now);
        expect(post.content, 'This is a test post with all properties');
        expect(post.tags, ['question', 'health']);
        expect(post.likeCount, 10);
        expect(post.commentCount, 5);
        expect(post.imageUrls, ['image1.jpg', 'image2.jpg']);
        expect(post.isAnonymous, true);
        expect(post.isPinned, true);
      });
    });

    // Test fromMap Factory Method
    group('fromMap', () {
      test('should create a CommunityPost from a complete map', () {
        final now = DateTime.now();
        final map = {
          'id': '123',
          'authorId': 'user456',
          'authorName': 'Jane Doe',
          'authorAvatar': 'avatar.jpg',
          'createdAt': now,
          'content': 'This is a test post',
          'tags': ['question', 'health'],
          'likeCount': 10,
          'commentCount': 5,
          'imageUrls': ['image1.jpg', 'image2.jpg'],
          'isAnonymous': true,
          'isPinned': true,
        };

        final post = CommunityPost.fromMap(map);

        expect(post.id, '123');
        expect(post.authorId, 'user456');
        expect(post.authorName, 'Jane Doe');
        expect(post.authorAvatar, 'avatar.jpg');
        expect(post.createdAt, now);
        expect(post.content, 'This is a test post');
        expect(post.tags, ['question', 'health']);
        expect(post.likeCount, 10);
        expect(post.commentCount, 5);
        expect(post.imageUrls, ['image1.jpg', 'image2.jpg']);
        expect(post.isAnonymous, true);
        expect(post.isPinned, true);
      });

      test('should handle missing fields with default values', () {
        final map = {
          'id': '123',
          'authorId': 'user456',
          'createdAt': DateTime.now(),
          'content': 'This is a test post',
        };

        final post = CommunityPost.fromMap(map);

        expect(post.id, '123');
        expect(post.authorId, 'user456');
        expect(post.authorName, 'Unknown'); // Default value
        expect(post.authorAvatar, ''); // Default value
        expect(post.content, 'This is a test post');
        expect(post.tags, isEmpty); // Default empty list
        expect(post.likeCount, 0); // Default value
        expect(post.commentCount, 0); // Default value
        expect(post.imageUrls, null); // Default value
        expect(post.isAnonymous, false); // Default value
        expect(post.isPinned, false); // Default value
      });

      test('should handle Timestamp createdAt field', () {
        // Create a timestamp for Jan 1, 2023
        final timestamp = MockTimestamp(1672531200, 0); // Jan 1, 2023
        final expectedDateTime = DateTime(2023, 1, 1);

        final map = {
          'id': '123',
          'authorId': 'user456',
          'authorName': 'Jane Doe',
          'content': 'This is a test post',
          'createdAt': timestamp,
          'tags': [],
        };

        final post = CommunityPost.fromMap(map);

        // Compare year, month, day to avoid millisecond differences
        expect(post.createdAt.year, expectedDateTime.year);
        expect(post.createdAt.month, expectedDateTime.month);
        expect(post.createdAt.day, expectedDateTime.day);
      });

      test('should handle String createdAt field', () {
        final dateString = '2023-01-01T12:00:00.000';
        final expectedDateTime = DateTime(2023, 1, 1, 12);

        final map = {
          'id': '123',
          'authorId': 'user456',
          'authorName': 'Jane Doe',
          'content': 'This is a test post',
          'createdAt': dateString,
          'tags': [],
        };

        final post = CommunityPost.fromMap(map);

        expect(post.createdAt, expectedDateTime);
      });

      test('should handle missing createdAt field', () {
        final map = {
          'id': '123',
          'authorId': 'user456',
          'authorName': 'Jane Doe',
          'content': 'This is a test post',
          'tags': [],
        };

        final post = CommunityPost.fromMap(map);

        // Should default to current time, just verify it's a DateTime
        expect(post.createdAt, isA<DateTime>());
      });

      test('should handle empty tags list', () {
        final map = {
          'id': '123',
          'authorId': 'user456',
          'authorName': 'Jane Doe',
          'content': 'This is a test post',
          'createdAt': DateTime.now(),
          'tags': [],
        };

        final post = CommunityPost.fromMap(map);

        expect(post.tags, isEmpty);
        expect(post.tags, isA<List<String>>());
      });

      test('should handle null tags field', () {
        final map = {
          'id': '123',
          'authorId': 'user456',
          'authorName': 'Jane Doe',
          'content': 'This is a test post',
          'createdAt': DateTime.now(),
        };

        final post = CommunityPost.fromMap(map);

        expect(post.tags, isEmpty);
        expect(post.tags, isA<List<String>>());
      });

      test('should handle null imageUrls field', () {
        final map = {
          'id': '123',
          'authorId': 'user456',
          'authorName': 'Jane Doe',
          'content': 'This is a test post',
          'createdAt': DateTime.now(),
          'tags': [],
        };

        final post = CommunityPost.fromMap(map);

        expect(post.imageUrls, null);

        print('Test completed successfully!');
      });

      test('should handle imageUrls field', () {
        final map = {
          'id': '123',
          'authorId': 'user456',
          'authorName': 'Jane Doe',
          'content': 'This is a test post',
          'createdAt': DateTime.now(),
          'tags': [],
          'imageUrls': ['image1.jpg', 'image2.jpg'],
        };

        final post = CommunityPost.fromMap(map);

        expect(post.imageUrls, ['image1.jpg', 'image2.jpg']);
        expect(post.imageUrls, isA<List<String>>());
      });
    });

    // Test toMap Method
    group('toMap', () {
      test('should convert CommunityPost to a map correctly', () {
        final now = DateTime(2023, 1, 1, 12); // Use fixed date for testing

        final post = CommunityPost(
          id: '123',
          authorId: 'user456',
          authorName: 'Jane Doe',
          authorAvatar: 'avatar.jpg',
          createdAt: now,
          content: 'This is a test post',
          tags: ['question', 'health'],
          likeCount: 10,
          commentCount: 5,
          imageUrls: ['image1.jpg', 'image2.jpg'],
          isAnonymous: true,
          isPinned: true, // This should not be included in the map
        );

        final map = post.toMap();

        expect(map['id'], '123');
        expect(map['authorId'], 'user456');
        expect(map['authorName'], 'Jane Doe');
        expect(map['authorAvatar'], 'avatar.jpg');
        expect(map['createdAt'], '2023-01-01T12:00:00.000');
        expect(map['content'], 'This is a test post');
        expect(map['tags'], ['question', 'health']);
        expect(map['likeCount'], 10);
        expect(map['commentCount'], 5);
        expect(map['imageUrls'], ['image1.jpg', 'image2.jpg']);
        expect(map['isAnonymous'], true);
        expect(
          map.containsKey('isPinned'),
          false,
        ); // Should not be included in the map
      });
    });

    // Test round-trip conversion (object -> map -> object)
    test(
      'should maintain consistency in round-trip conversion (except isPinned)',
      () {
        final now = DateTime(2023, 1, 1, 12); // Use fixed date for testing

        final originalPost = CommunityPost(
          id: '123',
          authorId: 'user456',
          authorName: 'Jane Doe',
          authorAvatar: 'avatar.jpg',
          createdAt: now,
          content: 'This is a test post',
          tags: ['question', 'health'],
          likeCount: 10,
          commentCount: 5,
          imageUrls: ['image1.jpg', 'image2.jpg'],
          isAnonymous: true,
          isPinned: true, // This will be lost in round-trip conversion
        );

        final map = originalPost.toMap();
        final recreatedPost = CommunityPost.fromMap(map);

        expect(recreatedPost.id, originalPost.id);
        expect(recreatedPost.authorId, originalPost.authorId);
        expect(recreatedPost.authorName, originalPost.authorName);
        expect(recreatedPost.authorAvatar, originalPost.authorAvatar);
        expect(recreatedPost.createdAt, originalPost.createdAt);
        expect(recreatedPost.content, originalPost.content);
        expect(recreatedPost.tags, originalPost.tags);
        expect(recreatedPost.likeCount, originalPost.likeCount);
        expect(recreatedPost.commentCount, originalPost.commentCount);
        expect(recreatedPost.imageUrls, originalPost.imageUrls);
        expect(recreatedPost.isAnonymous, originalPost.isAnonymous);
        expect(
          recreatedPost.isPinned,
          false,
        ); // Should be false as it's not included in toMap
      },
    );
  });
}
