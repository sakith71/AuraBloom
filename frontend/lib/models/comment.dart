// lib/models/comment.dart
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
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      postId: map['postId'],
      authorId: map['authorId'],
      authorName: map['authorName'],
      authorAvatar: map['authorAvatar'] ?? '',
      createdAt:
          map['createdAt'] is DateTime
              ? map['createdAt']
              : DateTime.parse(map['createdAt']),
      content: map['content'],
      isAnonymous: map['isAnonymous'] ?? false,
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
    };
  }
}
