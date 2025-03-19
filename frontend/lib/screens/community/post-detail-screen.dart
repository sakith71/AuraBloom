// lib/screens/community/post-detail-screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/community-models.dart';
import 'package:frontend/services/community-service.dart';

class PostDetailScreen extends StatefulWidget {
  final CommunityPost post;

  const PostDetailScreen({super.key, required this.post});

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final CommunityService _communityService = CommunityService();
  final TextEditingController _commentController = TextEditingController();
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isLiking = false;
  bool _userHasLiked = false;
  bool _isAnonymousComment = false; // Added for anonymous comment toggle
  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void initState() {
    super.initState();
    _loadComments();
    _checkIfUserLiked();

    // Debug post data
    if (kDebugMode) {
      print('Post author name: ${widget.post.authorName}');
      print('Post is anonymous: ${widget.post.isAnonymous}');
    }
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final comments = await _communityService.getCommentsForPost(
        widget.post.id,
      );

      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to load comments: $e')),
        );
      }
    }
  }

  Future<void> _checkIfUserLiked() async {
    try {
      final userId = _communityService.currentUser?.uid ?? 'anonymous';
      final hasLiked = await _communityService.hasUserLikedPost(
        widget.post.id,
        userId,
      );

      if (mounted) {
        setState(() {
          _userHasLiked = hasLiked;
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    final user = _communityService.currentUser;
    if (user == null) {
      _scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('You need to be logged in to comment')),
      );
      return;
    }

    // Get user display name with improved logic
    String authorName;

    if (_isAnonymousComment) {
      authorName = 'Anonymous';
    } else {
      authorName = _communityService.getUserDisplayName();

      // Debug output of what name we're using
      if (kDebugMode) {
        print('Adding comment with author name: $authorName');
        print('User display name: ${user.displayName}');
        print('User email: ${user.email}');
        print('Comment is anonymous: $_isAnonymousComment');
      }
    }

    final newComment = Comment(
      id: '', // Will be updated by the service
      postId: widget.post.id,
      authorId: user.uid,
      authorName: authorName,
      authorAvatar: user.photoURL ?? '',
      createdAt: DateTime.now(),
      content: _commentController.text.trim(),
      isAnonymous: _isAnonymousComment,
    );

    try {
      await _communityService.addComment(newComment);
      _commentController.clear();
      _loadComments();

      // Update the post's comment count in UI
      if (mounted) {
        setState(() {
          widget.post.commentCount += 1;
        });
      }
    } catch (e) {
      if (mounted) {
        _scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to add comment: $e')),
        );
      }
    }
  }

  Future<void> _deletePost() async {
    bool isDeleting = true;

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return WillPopScope(
            onWillPop: () async => !isDeleting,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    }

    try {
      await _communityService.deletePost(widget.post.id);
      isDeleting = false;

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context, true);
      }
    } catch (e) {
      isDeleting = false;

      if (mounted) {
        Navigator.pop(context);
        _scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to delete post: $e')),
        );
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await _communityService.deleteComment(commentId, widget.post.id);
      _loadComments();

      if (mounted) {
        setState(() {
          widget.post.commentCount -= 1;
        });
      }
    } catch (e) {
      if (mounted) {
        _scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to delete comment: $e')),
        );
      }
    }
  }

  Future<void> _likePost() async {
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
    });

    try {
      final userId = _communityService.currentUser?.uid ?? 'anonymous';
      await _communityService.likePost(widget.post.id, userId);

      if (mounted) {
        setState(() {
          _isLiking = false;
          _userHasLiked = !_userHasLiked;
          if (_userHasLiked) {
            widget.post.likeCount += 1;
          } else {
            widget.post.likeCount -= 1;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
        _scaffoldMessenger.showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getInitial(String name) {
    if (name.isEmpty) return 'U';

    if (name.contains('@')) {
      return name.split('@')[0][0].toUpperCase();
    }

    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('Building PostDetailScreen with author: ${widget.post.authorName}');
    }

    return Scaffold(
      // Updated background color to use the global scaffold background color.
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Post Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              if (_communityService.currentUser?.uid == widget.post.authorId) {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Post Options'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              title: const Text('Delete Post'),
                              onTap: () {
                                Navigator.pop(context);
                                _deletePost();
                              },
                            ),
                          ],
                        ),
                      ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    widget.post.isAnonymous
                                        ? Colors.grey
                                        : Colors.purple,
                                radius: 20,
                                child: Text(
                                  widget.post.isAnonymous
                                      ? 'A'
                                      : _getInitial(widget.post.authorName),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.post.isAnonymous
                                          ? 'Anonymous'
                                          : widget.post.authorName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      _formatDate(widget.post.createdAt),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.post.content,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          if (widget.post.imageUrls != null &&
                              widget.post.imageUrls!.isNotEmpty)
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    widget.post.imageUrls![0],
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          if (widget.post.imageUrls != null &&
                              widget.post.imageUrls!.length > 1)
                            Container(
                              height: 80,
                              margin: const EdgeInsets.only(top: 8),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.post.imageUrls!.length - 1,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 80,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          widget.post.imageUrls![index + 1],
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            children:
                                widget.post.tags
                                    .map(
                                      (tag) => Chip(
                                        label: Text(
                                          tag,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                        backgroundColor: Colors.blue,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        padding: EdgeInsets.zero,
                                        labelPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 0,
                                            ),
                                      ),
                                    )
                                    .toList(),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              InkWell(
                                onTap: _likePost,
                                child: Row(
                                  children: [
                                    _isLiking
                                        ? SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.red,
                                          ),
                                        )
                                        : Icon(
                                          _userHasLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          size: 18,
                                          color: Colors.red,
                                        ),
                                    const SizedBox(width: 4),
                                    Text('${widget.post.likeCount} Likes'),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.comment_outlined,
                                    size: 18,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text('${widget.post.commentCount} Comments'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Comments',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _comments.isEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No comments yet. Be the first to comment!',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      )
                      : Column(
                        children:
                            _comments
                                .map((comment) => _buildCommentCard(comment))
                                .toList(),
                      ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Switch(
                      value: _isAnonymousComment,
                      onChanged: (value) {
                        setState(() {
                          _isAnonymousComment = value;
                        });
                      },
                      activeColor: Colors.pink,
                    ),
                    Text(
                      'Post as anonymous',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        maxLines: null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _addComment,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 228, 77, 173),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(Comment comment) {
    if (kDebugMode) {
      print('Building comment card with author: ${comment.authorName}');
      print('Comment is anonymous: ${comment.isAnonymous}');
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      comment.isAnonymous ? Colors.grey : Colors.purple[200],
                  radius: 16,
                  child: Text(
                    comment.isAnonymous ? 'A' : _getInitial(comment.authorName),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.isAnonymous ? 'Anonymous' : comment.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatDate(comment.createdAt),
                        style: TextStyle(color: Colors.grey[600], fontSize: 10),
                      ),
                    ],
                  ),
                ),
                if (_communityService.currentUser?.uid == comment.authorId)
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Delete Comment'),
                              content: const Text(
                                'Are you sure you want to delete this comment?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await _deleteComment(comment.id);
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );
                    },
                    child: Icon(
                      Icons.more_vert,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.content),
          ],
        ),
      ),
    );
  }
}
