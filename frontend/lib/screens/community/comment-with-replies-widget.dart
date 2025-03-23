import 'package:flutter/material.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/reply.dart';
import 'package:frontend/services/community-service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class CommentWithRepliesWidget extends StatefulWidget {
  final Comment comment;
  final String postId;
  final Function(String) onDelete;
  final bool isPostAuthor;

  const CommentWithRepliesWidget({
    super.key,
    required this.comment,
    required this.postId,
    required this.onDelete,
    this.isPostAuthor = false,
  });

  @override
  _CommentWithRepliesWidgetState createState() =>
      _CommentWithRepliesWidgetState();
}

class _CommentWithRepliesWidgetState extends State<CommentWithRepliesWidget> {
  final CommunityService _communityService = CommunityService();
  final TextEditingController _replyController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoadingReplies = false;
  bool _showReplies = false;
  bool _showReplyInput = false;
  bool _isSubmittingReply = false;
  bool _isAnonymous = false;
  List<Reply> _replies = [];

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _loadReplies() async {
    if (!_showReplies) {
      setState(() {
        _isLoadingReplies = true;
      });

      try {
        final replies = await _communityService.getRepliesForComment(
          widget.postId,
          widget.comment.id,
        );

        if (kDebugMode && replies.isNotEmpty) {
          print(
            'Loaded ${replies.length} replies for comment: ${widget.comment.id}',
          );
        }

        setState(() {
          _replies = replies;
          _showReplies = true;
          _isLoadingReplies = false;
        });
      } catch (e) {
        setState(() {
          _isLoadingReplies = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load replies: $e')));
      }
    } else {
      setState(() {
        _showReplies = false;
      });
    }
  }

  Future<void> _addReply() async {
    if (_replyController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isSubmittingReply = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get user display name with improved logic
      String authorName;
      if (_isAnonymous) {
        authorName = 'Anonymous';
      } else {
        authorName = _communityService.getUserDisplayName();

        if (kDebugMode) {
          print('Adding reply with author name: $authorName');
          print('User display name: ${user.displayName}');
          print('User email: ${user.email}');
          print('Reply is anonymous: $_isAnonymous');
        }
      }

      final reply = Reply(
        id: '', // Will be set by Firestore
        commentId: widget.comment.id,
        authorId: user.uid,
        authorName: authorName,
        authorAvatar: user.photoURL ?? '',
        createdAt: DateTime.now(),
        content: _replyController.text.trim(),
        isAnonymous: _isAnonymous,
      );

      await _communityService.addReply(reply);

      // Load the updated replies
      final replies = await _communityService.getRepliesForComment(
        widget.postId,
        widget.comment.id,
      );

      setState(() {
        _replies = replies;
        _showReplies = true;
        _isSubmittingReply = false;
        _replyController.clear();
        widget.comment.replyCount += 1; // Update reply count
      });
    } catch (e) {
      setState(() {
        _isSubmittingReply = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add reply: $e')));
    }
  }

  Future<void> _deleteReply(String replyId) async {
    try {
      await _communityService.deleteReply(
        widget.postId,
        widget.comment.id,
        replyId,
      );

      setState(() {
        _replies.removeWhere((reply) => reply.id == replyId);
        widget.comment.replyCount -= 1; // Update reply count
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete reply: $e')));
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
    final isUserAuthor = _auth.currentUser?.uid == widget.comment.authorId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment content and info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author avatar
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            widget.comment.isAnonymous
                                ? Colors.grey
                                : Colors.pinkAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.comment.isAnonymous
                              ? 'A'
                              : _getInitial(widget.comment.authorName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Name and comment
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.comment.isAnonymous
                                    ? 'Anonymous'
                                    : widget.comment.authorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (widget.isPostAuthor &&
                                  !widget.comment.isAnonymous &&
                                  _auth.currentUser?.uid ==
                                      widget.comment.authorId)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.pink[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'Author',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink,
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              Text(
                                _formatDate(widget.comment.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.comment.content,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Reply and Delete options
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 46),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showReplyInput = !_showReplyInput;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            'Reply',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ),
                      if (isUserAuthor)
                        InkWell(
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
                                        onPressed: () {
                                          Navigator.pop(context);
                                          widget.onDelete(widget.comment.id);
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
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 12,
                              right: 4,
                              top: 4,
                              bottom: 4,
                            ),
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.red[700],
                              ),
                            ),
                          ),
                        ),
                      const Spacer(),
                      if (widget.comment.replyCount > 0)
                        TextButton.icon(
                          onPressed: _loadReplies,
                          icon: Icon(
                            _showReplies
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                          label: Text(
                            _showReplies
                                ? 'Hide replies'
                                : '${widget.comment.replyCount} ${widget.comment.replyCount == 1 ? 'reply' : 'replies'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 0,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Reply input
          if (_showReplyInput)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _replyController,
                          decoration: InputDecoration(
                            hintText: 'Write a reply...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                color: Colors.pinkAccent,
                              ),
                            ),
                          ),
                          minLines: 1,
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _isSubmittingReply
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.pink,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                          : IconButton(
                            onPressed: _addReply,
                            icon: const Icon(
                              Icons.send_rounded,
                              color: Colors.pinkAccent,
                            ),
                            iconSize: 24,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _isAnonymous,
                        onChanged: (value) {
                          setState(() {
                            _isAnonymous = value ?? false;
                          });
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      const Text(
                        'Reply anonymously',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Replies loading indicator
          if (_isLoadingReplies)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                  strokeWidth: 2,
                ),
              ),
            ),

          // Display replies
          if (_showReplies && _replies.isNotEmpty)
            Container(
              padding: const EdgeInsets.only(left: 46, right: 12, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    _replies.map((reply) {
                      final isReplyAuthor =
                          _auth.currentUser?.uid == reply.authorId;

                      return Container(
                        margin: const EdgeInsets.only(top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Reply author avatar
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color:
                                        reply.isAnonymous
                                            ? Colors.grey
                                            : Colors.pinkAccent.withOpacity(
                                              0.7,
                                            ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      reply.isAnonymous
                                          ? 'A'
                                          : _getInitial(reply.authorName),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Reply content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            reply.isAnonymous
                                                ? 'Anonymous'
                                                : reply.authorName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          if (widget.isPostAuthor &&
                                              !reply.isAnonymous &&
                                              _auth.currentUser?.uid ==
                                                  reply.authorId)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                left: 8,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.pink[100],
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Text(
                                                'Author',
                                                style: TextStyle(
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.pink,
                                                ),
                                              ),
                                            ),
                                          const Spacer(),
                                          Text(
                                            _formatDate(reply.createdAt),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        reply.content,
                                        style: const TextStyle(fontSize: 13),
                                      ),

                                      // Delete reply option
                                      if (isReplyAuthor)
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: TextButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (context) => AlertDialog(
                                                      title: const Text(
                                                        'Delete Reply',
                                                      ),
                                                      content: const Text(
                                                        'Are you sure you want to delete this reply?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                  ),
                                                          child: const Text(
                                                            'Cancel',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                            _deleteReply(
                                                              reply.id,
                                                            );
                                                          },
                                                          child: const Text(
                                                            'Delete',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                            },
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 0,
                                                  ),
                                              minimumSize: Size.zero,
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Text(
                                              'Delete',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.red[700],
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
