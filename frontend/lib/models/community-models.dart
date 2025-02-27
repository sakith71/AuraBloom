class CommunityPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final DateTime createdAt;
  final String content;
  final List<String> tags;
  final int likeCount;
  final int commentCount;
  final List<String>? imageUrls;
  final bool isAnonymous;

  CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar = '',
    required this.createdAt,
    required this.content,
    required this.tags,
    this.likeCount = 0,
    this.commentCount = 0,
    this.imageUrls,
    this.isAnonymous = false,
  });

  // Convert from Map (e.g., from JSON)
  factory CommunityPost.fromMap(Map<String, dynamic> map) {
    return CommunityPost(
      id: map['id'],
      authorId: map['authorId'],
      authorName: map['authorName'],
      authorAvatar: map['authorAvatar'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      content: map['content'],
      tags: List<String>.from(map['tags']),
      likeCount: map['likeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      imageUrls:
          map['imageUrls'] != null ? List<String>.from(map['imageUrls']) : null,
      isAnonymous: map['isAnonymous'] ?? false,
    );
  }

  // Convert to Map (e.g., for JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'createdAt': createdAt.toIso8601String(),
      'content': content,
      'tags': tags,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'imageUrls': imageUrls,
      'isAnonymous': isAnonymous,
    };
  }
}

// models/comment.dart
class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final DateTime createdAt;
  final String content;
  final bool isAnonymous;

  Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar = '',
    required this.createdAt,
    required this.content,
    this.isAnonymous = false,
  }) {
    // TODO: implement
    throw UnimplementedError();
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    var comment = Comment(
      id: map['id'],
      postId: map['postId'],
      authorId: map['authorId'],
      authorName: map['authorName'],
      authorAvatar: map['authorAvatar'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      content: map['content'],
      isAnonymous: map['isAnonymous'] ?? false,
    );
    return comment;
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
    };
  }
}
