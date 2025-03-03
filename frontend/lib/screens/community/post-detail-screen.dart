// lib/screens/community/post-detail-screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/community-models.dart';
import 'package:frontend/models/reply.dart';
import 'package:frontend/services/community-service.dart';

class PostDetailScreen extends StatefulWidget {
  final CommunityPost post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final CommunityService _communityService = CommunityService();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();
  List<Comment> _comments = [];
  Map<String, List<Reply>> _replies = {};
  Map<String, bool> _expandedReplies = {};
  Map<String, bool> _loadingReplies = {};
  Map<String, bool> _showReplyField = {};
  bool _isLoading = true;
  bool _isLiking = false;
  bool _userHasLiked = false;

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

      // Debug comments data
      if (kDebugMode && comments.isNotEmpty) {
        print('First comment author: ${comments.first.authorName}');
      }

      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
          
          // Initialize maps for all comments
          for (var comment in comments) {
            _expandedReplies[comment.id] = false;
            _loadingReplies[comment.id] = false;
            _showReplyField[comment.id] = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load comments: $e')));
      }
    }
  }

  Future<void> _loadReplies(String commentId) async {
    setState(() {
      _loadingReplies[commentId] = true;
    });

    try {
      final replies = await _communityService.getRepliesForComment(
        widget.post.id,
        commentId,
      );

      if (mounted) {
        setState(() {
          _replies[commentId] = replies;
          _loadingReplies[commentId] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingReplies[commentId] = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load replies: $e')));
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to comment')),
      );
      return;
    }

    // Get user display name with improved logic
    String authorName;
    bool isAnonymous =
        false; // Set to true if you want anonymous comments as an option

    if (isAnonymous) {
      authorName = 'Anonymous';
    } else {
      // Use our robust getUserDisplayName method
      authorName = _communityService.getUserDisplayName();

      // Debug output of what name we're using
      if (kDebugMode) {
        print('Adding comment with author name: $authorName');
        print('User display name: ${user.displayName}');
        print('User email: ${user.email}');
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
      isAnonymous: isAnonymous,
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add comment: $e')));
      }
    }
  }

  Future<void> _addReply(String commentId) async {
    if (_replyController.text.trim().isEmpty) {
      return;
    }

    final user = _communityService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to reply')),
      );
      return;
    }

    // Get user display name with improved logic
    String authorName;
    bool isAnonymous = false;

    if (isAnonymous) {
      authorName = 'Anonymous';
    } else {
      authorName = _communityService.getUserDisplayName();
    }

    final newReply = Reply(
      id: '', // Will be updated by the service
      commentId: commentId,
      authorId: user.uid,
      authorName: authorName,
      authorAvatar: user.photoURL ?? '',
      createdAt: DateTime.now(),
      content: _replyController.text.trim(),
      isAnonymous: isAnonymous,
    );

    try {
      await _communityService.addReply(newReply);
      _replyController.clear();
      
      // Find the comment to update its reply count
      int commentIndex = _comments.indexWhere((c) => c.id == commentId);
      if (commentIndex != -1) {
        setState(() {
          _comments[commentIndex].replyCount += 1;
          _showReplyField[commentId] = false;
        });
        
        // If replies are already expanded, refresh them
        if (_expandedReplies[commentId] == true) {
          _loadReplies(commentId);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add reply: $e')));
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await _communityService.deleteComment(commentId, widget.post.id);
      _loadComments();

      // Update the post's comment count in UI
      if (mounted) {
        setState(() {
          widget.post.commentCount -= 1;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete comment: $e')));
      }
    }
  }

  Future<void> _deleteReply(String commentId, String replyId) async {
    try {
      await _communityService.deleteReply(widget.post.id, commentId, replyId);
      
      // Refresh replies and update the reply count
      _loadReplies(commentId);
      
      // Update comment's reply count in UI
      int commentIndex = _comments.indexWhere((c) => c.id == commentId);
      if (commentIndex != -1 && mounted) {
        setState(() {
          _comments[commentIndex].replyCount -= 1;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete reply: $e')));
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

      // Update the UI
      if (mounted) {
        setState(() {
          _isLiking = false;
          _userHasLiked = !_userHasLiked; // Toggle like status

          // Update like count based on the action (like or unlike)
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  void _toggleReplies(String commentId) {
    setState(() {
      _expandedReplies[commentId] = !(_expandedReplies[commentId] ?? false);
      
      // Load replies if they're being expanded and haven't been loaded yet
      if (_expandedReplies[commentId] == true && 
          (!_replies.containsKey(commentId) || _replies[commentId]!.isEmpty)) {
        _loadReplies(commentId);
      }
    });
  }

  void _toggleReplyField(String commentId) {
    setState(() {
      // Close any other open reply fields
      _showReplyField.forEach((key, value) {
        if (key != commentId) {
          _showReplyField[key] = false;
        }
      });
      
      // Toggle this one
      _showReplyField[commentId] = !(_showReplyField[commentId] ?? false);
    });
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

  // Get initial for avatar
  String _getInitial(String name) {
    if (name.isEmpty) return 'U';

    // If it's an email address, get the first letter before the @ symbol
    if (name.contains('@')) {
      return name.split('@')[0][0].toUpperCase();
    }

    // Otherwise get the first letter of the name
    return name[0].toUpperCase();
  }

  Widget _buildCommentCard(Comment comment) {
    // Debug comment data
    if (kDebugMode) {
      print('Building comment card with author: ${comment.authorName}');
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comment header - author info and time
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: comment.isAnonymous ? Colors.grey : Colors.purple[200],
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
                        comment.authorName,
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
                // Delete option if user is the author
                if (_communityService.currentUser?.uid == comment.authorId)
                  GestureDetector(
                    onTap: () {
                      // Show delete confirmation
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
            
            // Comment content
            Text(comment.content),
            
            const SizedBox(height: 8),
            
            // Reply action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Reply button
                TextButton.icon(
                  onPressed: () => _toggleReplyField(comment.id),
                  icon: Icon(
                    Icons.reply,
                    size: 16,
                    color: Colors.blue[400],
                  ),
                  label: Text(
                    'Reply',
                    style: TextStyle(
                      color: Colors.blue[400],
                      fontSize: 12,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                
                // Show replies button (only if there are replies)
                if (comment.replyCount > 0)
                  TextButton.icon(
                    onPressed: () => _toggleReplies(comment.id),
                    icon: Icon(
                      _expandedReplies[comment.id] == true 
                          ? Icons.keyboard_arrow_up 
                          : Icons.keyboard_arrow_down,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    label: Text(
                      _expandedReplies[comment.id] == true
                          ? 'Hide Replies'
                          : '${comment.replyCount} ${comment.replyCount == 1 ? 'Reply' : 'Replies'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
            
            // Reply input field
            if (_showReplyField[comment.id] == true)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        decoration: InputDecoration(
                          hintText: 'Write a reply...',
                          hintStyle: TextStyle(fontSize: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          isDense: true,
                        ),
                        style: TextStyle(fontSize: 14),
                        maxLines: null,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _addReply(comment.id),
                      icon: Icon(
                        Icons.send,
                        size: 18,
                        color: Color.fromARGB(255, 228, 77, 173),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
            
            // Expanded replies section
            if (_expandedReplies[comment.id] == true)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 16),
                child: _loadingReplies[comment.id] == true
                    ? Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Column(
                        children: _replies.containsKey(comment.id) && _replies[comment.id]!.isNotEmpty
                            ? _replies[comment.id]!
                                .map((reply) => _buildReplyCard(comment.id, reply))
                                .toList()
                            : [
                                Text(
                                  'No replies yet',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyCard(String commentId, Reply reply) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reply header
          Row(
            children: [
              CircleAvatar(
                backgroundColor: reply.isAnonymous ? Colors.grey : Colors.blue[100],
                radius: 12,
                child: Text(
                  reply.isAnonymous ? 'A' : _getInitial(reply.authorName),
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reply.authorName,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDate(reply.createdAt),
                      style: TextStyle(color: Colors.grey[500], fontSize: 10),
                    ),
                  ],
                ),
              ),
              // Delete option if user is the author
              if (_communityService.currentUser?.uid == reply.authorId)
                GestureDetector(
                  onTap: () {
                    // Show delete confirmation
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Reply'),
                        content: const Text(
                          'Are you sure you want to delete this reply?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _deleteReply(commentId, reply.id);
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
                    size: 14,
                    color: Colors.grey[400],
                  ),
                ),
            ],
          ),
          
          // Reply content
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 28),
            child: Text(
              reply.content,
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Extra debugging for post author name
    if (kDebugMode) {
      print('Building PostDetailScreen with author: ${widget.post.authorName}');
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 189, 228),
      appBar: AppBar(
        title: const Text(
          'Post Details',
          style: TextStyle(
            color: Colors.black, // Change text color to black
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // Make background transparent
        elevation: 0, // Remove shadow
        iconTheme: const IconThemeData(
          color: Colors.black,
        ), // Make back button black
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
            ), // Make menu icon black
            onPressed: () {
              // Your existing code for showing options menu
              if (_communityService.currentUser?.uid == widget.post.authorId) {
                // Keep your existing showDialog code here
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
                              onTap: () async {
                                Navigator.pop(context);
                                try {
                                  await _communityService.deletePost(
                                    widget.post.id,
                                  );
                                  if (mounted) {
                                    Navigator.pop(context, true);
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to delete post: $e',
                                        ),
                                      ),
                                    );
                                  }
                                }
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
          // Post content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post card
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Author info
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
                          // Post content
                          Text(
                            widget.post.content,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          // Post image if available
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
                          // If there are multiple images, show them in a row
                          if (widget.post.imageUrls != null &&
                              widget.post.imageUrls!.length > 1)
                            Container(
                              height: 80,
                              margin: const EdgeInsets.only(top: 8),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.post.imageUrls!.length - 1,
                                itemBuilder: (context, index) {
                                  // Start from index 1 since we already showed the first image
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
                          // Tags
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
                          // Like and comment counts
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

                  // Comments section
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
                            _comments.map((comment) => _buildCommentCard(comment)).toList(),
                      ),
                ],
              ),
            ),
          ),

          // Comment input
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
            child: Row(
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
          ),
        ],
      ),
    );
  }
} 