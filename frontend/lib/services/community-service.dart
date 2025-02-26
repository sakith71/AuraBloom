import 'package:frontend/models/community-models.dart';


class CommunityService {
  // Simulate a database/API with in-memory storage for now
  final List<CommunityPost> _posts = [];
  final List<Comment> _comments = [];
  
  // Get all posts
  Future<List<CommunityPost>> getPosts() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800));
    return [..._posts];
  }
  
  // Get posts filtered by tag
  Future<List<CommunityPost>> getPostsByTag(String tag) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _posts.where((post) => post.tags.contains(tag)).toList();
  }
  
  // Add a new post
  Future<CommunityPost> createPost(CommunityPost post) async {
    await Future.delayed(Duration(milliseconds: 1000));
    _posts.add(post);
    return post;
  }
  
  // Get comments for a post
  Future<List<Comment>> getCommentsForPost(String postId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _comments.where((comment) => comment.postId == postId).toList();
  }
  
  // Add a comment to a post
  Future<Comment> addComment(Comment comment) async {
    await Future.delayed(Duration(milliseconds: 800));
    _comments.add(comment);
    
    // Update the comment count on the post
    final postIndex = _posts.indexWhere((post) => post.id == comment.postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      _posts[postIndex] = CommunityPost(
        id: post.id,
        authorId: post.authorId,
        authorName: post.authorName,
        authorAvatar: post.authorAvatar,
        createdAt: post.createdAt,
        content: post.content,
        tags: post.tags,
        likeCount: post.likeCount,
        commentCount: post.commentCount + 1,
        imageUrls: post.imageUrls,
        isAnonymous: post.isAnonymous,
      );
    }
    
    return comment;
  }
  
  // Like a post
  Future<void> likePost(String postId, String userId) async {
    await Future.delayed(Duration(milliseconds: 300));
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      _posts[postIndex] = CommunityPost(
        id: post.id,
        authorId: post.authorId,
        authorName: post.authorName,
        authorAvatar: post.authorAvatar,
        createdAt: post.createdAt,
        content: post.content,
        tags: post.tags,
        likeCount: post.likeCount + 1,
        commentCount: post.commentCount,
        imageUrls: post.imageUrls,
        isAnonymous: post.isAnonymous,
      );
    }
  }

  // Initialize with some sample data
  void initializeSampleData() {
    _posts.addAll([
      CommunityPost(
        id: '1',
        authorId: 'user1',
        authorName: 'Kiyara Fero',
        createdAt: DateTime(2023, 11, 12),
        content: 'I found these stretching exercises really helpful for managing my cramps. Has anyone else tried yoga for period pain?',
        tags: ['Exercises', 'Diets'],
        likeCount: 14,
        commentCount: 3,
      ),
      CommunityPost(
        id: '2',
        authorId: 'user2',
        authorName: 'Trisha G.',
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        content: 'Heat therapy has been my go-to for pain management. I also found that avoiding certain foods has helped reduce bloating.',
        tags: ['Pain Management', 'Diets'],
        likeCount: 10,
        commentCount: 1,
      ),
    ]);

    var comment2 = Comment(
        id: 'c4',
        postId: '2',
        authorId: 'user5',
        authorName: 'Sophie T.',
        createdAt: DateTime.now().subtract(Duration(hours: 1)),
        content: 'What foods do you avoid? I have been trying to figure out my triggers.',
      );
    var comment = comment2;
    _comments.addAll([
      Comment(
        id: 'c1',
        postId: '1',
        authorId: 'user3',
        authorName: 'Maya L.',
        createdAt: DateTime.now().subtract(Duration(days: 2)),
        content: 'Yes! Childs pose and gentle twists have been amazing for me.',
      ),
      Comment(
        id: 'c2',
        postId: '1',
        authorId: 'user4',
        authorName: 'Jenna K.',
        createdAt: DateTime.now().subtract(Duration(days: 1, hours: 5)),
        content: 'Could you share your routine? I am looking to start yoga specifically for period pain.',
      ),
      Comment(
        id: 'c3',
        postId: '1',
        authorId: 'user1',
        authorName: 'Kiyara Fero',
        createdAt: DateTime.now().subtract(Duration(hours: 12)),
        content: 'Sure! I will make a detailed post about it tomorrow with all the poses I find helpful.',
      ),
      comment,
    ]);
  }
}