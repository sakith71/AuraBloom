import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/providers/community-provider.dart';

void main() {
  group('PostModel', () {
    test('Creates a post model correctly', () {
      final post = PostModel(
        username: 'TestUser',
        date: '2023-01-01',
        tags: ['health', 'wellness'],
        likes: 10,
        comments: 5,
        content: 'Test post content',
        isAnonymous: false,
      );

      expect(post.username, 'TestUser');
      expect(post.date, '2023-01-01');
      expect(post.tags, ['health', 'wellness']);
      expect(post.likes, 10);
      expect(post.comments, 5);
      expect(post.content, 'Test post content');
      expect(post.isAnonymous, false);
    });

    test('Creates an anonymous post model', () {
      final post = PostModel(
        username: 'Anonymous',
        date: '2023-01-01',
        tags: [],
        likes: 0,
        comments: 0,
        content: 'Anonymous post content',
        isAnonymous: true,
      );

      expect(post.username, 'Anonymous');
      expect(post.isAnonymous, true);
    });
  });

  group('CommunityProvider', () {
    late CommunityProvider provider;

    setUp(() {
      provider = CommunityProvider();
    });

    test('Initial posts list is empty', () {
      expect(provider.posts, isEmpty);
    });

    test('Adds a non-anonymous post correctly', () {
      // Arrange
      final initialPostCount = provider.posts.length;

      // Act
      provider.addPost('Test content', false);

      // Assert
      expect(provider.posts.length, initialPostCount + 1);
      final addedPost = provider.posts.last;
      expect(addedPost.username, 'User');
      expect(addedPost.content, 'Test content');
      expect(addedPost.isAnonymous, false);
      expect(addedPost.likes, 0);
      expect(addedPost.comments, 0);
      expect(addedPost.date, 'Just now');
      expect(addedPost.tags, isEmpty);
    });

    test('Adds an anonymous post correctly', () {
      // Arrange
      final initialPostCount = provider.posts.length;

      // Act
      provider.addPost('Anonymous content', true);

      // Assert
      expect(provider.posts.length, initialPostCount + 1);
      final addedPost = provider.posts.last;
      expect(addedPost.username, 'Anonymous');
      expect(addedPost.content, 'Anonymous content');
      expect(addedPost.isAnonymous, true);
      expect(addedPost.likes, 0);
      expect(addedPost.comments, 0);
      expect(addedPost.date, 'Just now');
      expect(addedPost.tags, isEmpty);
    });

    test('Notifies listeners when a post is added', () {
      // Arrange
      var listenerCalled = false;
      provider.addListener(() {
        listenerCalled = true;
      });

      // Act
      provider.addPost('Test post', false);

      // Assert
      expect(listenerCalled, isTrue);
    });

    test('Multiple posts can be added', () {
      // Act
      provider.addPost('First post', false);
      provider.addPost('Second post', true);
      provider.addPost('Third post', false);

      // Assert
      expect(provider.posts.length, 3);
      expect(provider.posts[0].content, 'First post');
      expect(provider.posts[1].content, 'Second post');
      expect(provider.posts[2].content, 'Third post');

      print('Test completed successfully!');
    });
  });
}
