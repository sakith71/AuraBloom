import 'package:flutter/material.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/community-models.dart';
import 'package:frontend/services/community-service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostDetailScreen extends StatefulWidget {
  final CommunityPost post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

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

  @override
  void initState() {
    super.initState();
    // Delay loading to ensure the widget is properly mounted
    Future.delayed(Duration.zero, () {
      if (mounted) {
        _loadComments();
        _checkIfUserLiked();
      }
    });
  }

  Future<void> _loadComments() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      print('Loading comments for post: ${widget.post.id}');
      
      // Get comments directly from Firestore to bypass any caching issues
      final snapshot = await FirebaseFirestore.instance
          .collection('comments')
          .where('postId', isEqualTo: widget.post.id)
          .get();
      
      print('Found ${snapshot.docs.length} comments');
      
      if (!mounted) return;
      
      final comments = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        
        try {
          return Comment.fromMap(data);
        } catch (e) {
          print('Error parsing comment: $e');
          return Comment(
            id: doc.id,
            postId: widget.post.id,
            authorId: 'error',
            authorName: 'Error loading',
            createdAt: DateTime.now(),
            content: 'Error loading comment',
          );
        }
      }).toList();
      
      // Sort manually
      comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading comments: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _comments = []; // Ensure we have an empty list rather than null
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load comments: $e'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadComments,
            ),
          ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to be logged in to comment')),
      );
      return;
    }

    final newComment = Comment(
      id: '', // Will be updated by the service
      postId: widget.post.id,
      authorId: user.uid,
      authorName: user.displayName ?? 'User',
      authorAvatar: user.photoURL ?? '',
      createdAt: DateTime.now(),
      content: _commentController.text.trim(),
      isAnonymous: false,
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
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment added successfully')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add comment: $e')));
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

  // Helper debug method that can be called if problems persist
  Future<void> _debugLoadComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Try to get the raw comments collection data
      final commentsSnapshot = await FirebaseFirestore.instance
          .collection('comments')
          .get();
      
      print('Debug: Total comments in database: ${commentsSnapshot.docs.length}');
      
      // Step 2: Check if any comments match our post ID
      final matchingComments = commentsSnapshot.docs
          .where((doc) => (doc.data() as Map<String, dynamic>)['postId'] == widget.post.id)
          .toList();
      
      print('Debug: Comments matching this post: ${matchingComments.length}');
      
      if (matchingComments.isNotEmpty) {
        print('Debug: First matching comment: ${matchingComments.first.data()}');
      }
      
      // Step 3: Try the direct query
      final directQuery = await FirebaseFirestore.instance
          .collection('comments')
          .where('postId', isEqualTo: widget.post.id)
          .get();
      
      print('Debug: Direct query results: ${directQuery.docs.length}');
      
      // Continue with normal comment loading
      final comments = directQuery.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Comment.fromMap(data);
      }).toList();
      
      // Sort manually
      comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Debug: Error fetching comments: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _comments = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _debugLoadComments,
            ),
          ),
        );
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

  @override
  Widget build(BuildContext context) {
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
                                      : (widget.post.authorName.isNotEmpty
                                          ? widget.post.authorName[0]
                                          : 'U'),
                                  style: const TextStyle(color: Colors.white),
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
                  
                  // Comments section with improved UI
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Comments',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            if (_isLoading)
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.purple,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text('Loading comments...'),
                                ),
                              )
                            : _comments.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        children: [
                                          Text(
                                            'No comments yet. Be the first to comment!',
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                          const SizedBox(height: 16),
                                          TextButton.icon(
                                            onPressed: _debugLoadComments,
                                            icon: const Icon(Icons.refresh),
                                            label: const Text('Debug Load Comments'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.purple,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: _comments
                                        .map((comment) => _buildCommentCard(comment))
                                        .toList(),
                                  ),
                      ],
                    ),
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

  Widget _buildCommentCard(Comment comment) {
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
                  backgroundColor: Colors.purple[200],
                  radius: 16,
                  child: Text(
                    comment.authorName.isNotEmpty ? comment.authorName[0] : 'U',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatDate(comment.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                  ],
                ),
                const Spacer(),
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
            Text(comment.content),
          ],
        ),
      ),
    );
  }
}