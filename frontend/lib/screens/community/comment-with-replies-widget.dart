// lib/screens/community/comment-with-replies-widget.dart
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
    Key? key,
    required this.comment,
    required this.postId,
    required this.onDelete,
    this.isPostAuthor = false,
  }) : super(key: key);

  @override
  _CommentWithRepliesWidgetState createState() => _CommentWithRepliesWidgetState();
}

class _CommentWithRepliesWidgetState extends State<CommentWithRepliesWidget> {
  final CommunityService _communityService = CommunityService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _replyController = TextEditingController();
  
  bool _showReplyInput = false;
  bool _isAnonymous = false;
  List<Reply> _replies = [];

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
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
                        color: widget.comment.isAnonymous
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
                                  _auth.currentUser?.uid == widget.comment.authorId)
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
                              builder: (context) => AlertDialog(
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
                            padding: const EdgeInsets.only(left: 12, right: 4, top: 4, bottom: 4),
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
                          onPressed: () {
                            // Will implement in next commit
                          },
                          icon: Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                          label: Text(
                            '${widget.comment.replyCount} ${widget.comment.replyCount == 1 ? 'reply' : 'replies'}',
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
        ],
      ),
    );
  }
}