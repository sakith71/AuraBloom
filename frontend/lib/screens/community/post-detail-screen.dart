import 'package:flutter/material.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/community-models.dart';
import 'package:frontend/services/community-service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/screens/community/comment-with-replies-widget.dart';

class PostDetailScreen extends StatefulWidget {
  final CommunityPost post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final CommunityService _communityService = CommunityService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _commentController = TextEditingController();
  
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isLiked = false;
  bool _isPostingComment = false;
  bool _isAnonymousComment = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _checkIfLiked();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final comments = await _communityService.getCommentsForPost(widget.post.id);
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load comments: $e')),
      );
    }
  }

  Future<void> _checkIfLiked() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final liked = await _communityService.hasUserLikedPost(
          widget.post.id,
          user.uid,
        );
        setState(() {
          _isLiked = liked;
        });
      } catch (e) {
        // Handle error quietly
      }
    }
  }

  Future<void> _toggleLike() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _communityService.likePost(widget.post.id, user.uid);
        
        // Toggle local state
        setState(() {
          _isLiked = !_isLiked;
          widget.post.likeCount += _isLiked ? 1 : -1;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to like post: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to like posts')),
      );
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _isPostingComment = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final comment = Comment(
        id: '', // Will be set by Firestore
        postId: widget.post.id,
        authorId: user.uid,
        authorName: _isAnonymousComment ? 'Anonymous' : _communityService.getUserDisplayName(),
        createdAt: DateTime.now(),
        content: _commentController.text.trim(),
        isAnonymous: _isAnonymousComment,
      );

      await _communityService.addComment(comment);
      
      // Reload comments
      await _loadComments();
      
      setState(() {
        _isPostingComment = false;
        _commentController.clear();
      });
    } catch (e) {
      setState(() {
        _isPostingComment = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post comment: $e')),
      );
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await _communityService.deleteComment(commentId, widget.post.id);
      await _loadComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete comment: $e')),
      );
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

  // Get color for tag
  Color _getTagColor(String tag) {
    switch (tag) {
      case 'Pain Management':
        return Colors.redAccent;
      case 'Exercises':
        return Colors.green;
      case 'Diets':
        return Colors.amber;
      case 'Reproductive Health':
        return Colors.pinkAccent;
      case 'Mental Health':
        return Colors.purple;
      default:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUserPostAuthor = _auth.currentUser?.uid == widget.post.authorId;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Post Detail'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          // More options menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String choice) async {
              if (choice == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Post'),
                    content: const Text('Are you sure you want to delete this post?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('DELETE'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  try {
                    await _communityService.deletePost(widget.post.id);
                    Navigator.pop(context, true); // Return true to indicate deletion
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to delete post: $e')),
                    );
                  }
                }
              }
else if (choice == 'pin') {
  try {
    final isPinned = await _communityService.togglePinPost(widget.post.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isPinned ? 'Post pinned successfully' : 'Post unpinned')),
    );
    
    // Update the local post object
    setState(() {
      widget.post.isPinned = isPinned;
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to pin post: $e')),
    );
  }
}
            },
            itemBuilder: (BuildContext context) {
              final List<PopupMenuEntry<String>> options = [];
              
              // Pin/Unpin option
              options.add(PopupMenuItem<String>(
                value: 'pin',
                child: Row(
                  children: [
                    Icon(
                      widget.post.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                      color: widget.post.isPinned ? Colors.amber : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(widget.post.isPinned ? 'Unpin Post' : 'Pin Post'),
                  ],
                ),
              ));
              
              // Delete option (only for post author)
              if (isUserPostAuthor) {
                options.add(const PopupMenuDivider());
                options.add(const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text('Delete Post'),
                    ],
                  ),
                ));
              }
              
              return options;
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Post content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post card
                  // Show pinned indicator if post is pinned
                  if (widget.post.isPinned)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.push_pin,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pinned Post',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Show pinned indicator if post is pinned
                        if (widget.post.isPinned)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.push_pin,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Pinned Post',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                        // Author info and time
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                          child: Row(
                            children: [
                              // Author avatar
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: widget.post.isAnonymous
                                      ? Colors.grey
                                      : Colors.pinkAccent,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    widget.post.isAnonymous
                                        ? 'A'
                                        : (widget.post.authorName.isNotEmpty
                                            ? widget.post.authorName[0]
                                            : 'U'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
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
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatDate(widget.post.createdAt),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Post content
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Text(
                            widget.post.content,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.4,
                            ),
                          ),
                        ),

                        // Image if available
                        if (widget.post.imageUrls != null &&
                            widget.post.imageUrls!.isNotEmpty)
                          Container(
                            height: 250,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              image: DecorationImage(
                                image: NetworkImage(widget.post.imageUrls![0]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                        // Tags
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tags as chips
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: widget.post.tags.map((tag) {
                                  final tagColor = _getTagColor(tag);
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: tagColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        color: tagColor.withOpacity(0.5),
                                      ),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: tagColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Likes and comments count
                              Row(
                                children: [
                                  InkWell(
                                    onTap: _toggleLike,
                                    child: Row(
                                      children: [
                                        Icon(
                                          _isLiked ? Icons.favorite : Icons.favorite_border,
                                          size: 22,
                                          color: Colors.redAccent,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${widget.post.likeCount}',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.chat_bubble_outline,
                                        size: 22,
                                        color: Colors.blueAccent,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${widget.post.commentCount}',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  // Share button
                                  IconButton(
                                    icon: const Icon(
                                      Icons.share_outlined,
                                      size: 22,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      // Share functionality
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Comments section header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Text(
                      'Comments (${_comments.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // Comments list
                  _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                            ),
                          ),
                        )
                      : _comments.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(30),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 60,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No comments yet. Be the first to comment!',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: _comments.length,
                              itemBuilder: (context, index) {
                                return CommentWithRepliesWidget(
                                  comment: _comments[index],
                                  postId: widget.post.id,
                                  onDelete: _deleteComment,
                                  isPostAuthor: isUserPostAuthor,
                                );
                              },
                            ),
                ],
              ),
            ),
          ),
          
          // Comment input section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          isDense: true,
                        ),
                        minLines: 1,
                        maxLines: 4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _isPostingComment
                        ? const Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
                              ),
                            ),
                          )
                        : IconButton(
                            onPressed: _addComment,
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.pink,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _isAnonymousComment,
                      onChanged: (value) {
                        setState(() {
                          _isAnonymousComment = value ?? false;
                        });
                      },
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    const Text(
                      'Comment anonymously',
                      style: TextStyle(fontSize: 12),
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
}