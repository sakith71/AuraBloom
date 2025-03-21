import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/community-models.dart';
import 'package:frontend/screens/community/post-detail-screen.dart';
import 'package:frontend/screens/create_post_screen.dart';
import 'package:frontend/services/community-service.dart';
import 'package:frontend/services/notification-service.dart';
import 'package:frontend/screens/notification-screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String selectedFilter = 'All';
  final List<String> filterOptions = [
    'All',
    'Pain Management',
    'Exercises',
    'Diets',
    'Reproductive Health',
    'Create Post',
  ];

  final CommunityService _communityService = CommunityService();
  final NotificationService _notificationService = NotificationService();
  List<CommunityPost> posts = [];
  bool isLoading = true;
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _listenForNotifications();
  }

  void _listenForNotifications() {
    _notificationService.getUnreadCount().listen((count) {
      if (mounted) {
        setState(() {
          _unreadNotificationCount = count;
        });
      }
    });
  }

  Future<void> _loadPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Listen to the stream of posts with user-specific pinned status
      _communityService.getPosts().listen((updatedPosts) {
        if (mounted) {
          setState(() {
            posts = updatedPosts;
            isLoading = false;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load posts: $e')));
      }
    }
  }

  void _navigateToCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );

    // If post was successfully created, refresh posts
    if (result == true) {
      setState(() {
        isLoading = true;
      });
      _loadPosts();
    }
  }

  void _navigateToPostDetail(CommunityPost post) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)),
    );

    // If post was updated or deleted, refresh posts
    if (result == true) {
      _loadPosts();
    }
  }

  void _navigateToNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationScreen()),
    );
  }

  List<CommunityPost> _getFilteredPosts() {
    List<CommunityPost> filteredPosts;

    if (selectedFilter == 'All') {
      filteredPosts = List.from(posts);
    } else {
      filteredPosts =
          posts.where((post) => post.tags.contains(selectedFilter)).toList();
    }

    // Sort the posts so that pinned posts appear at the top
    // Note: isPinned now reflects if the post is pinned by the current user
    filteredPosts.sort((a, b) {
      // First compare pinned status (pinned posts come first)
      if (a.isPinned && !b.isPinned) {
        return -1;
      } else if (!a.isPinned && b.isPinned) {
        return 1;
      }

      // If pinned status is the same, sort by creation date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });

    return filteredPosts;
  }

  // Get icon for category
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Pain Management':
        return Icons.healing;
      case 'Exercises':
        return Icons.fitness_center;
      case 'Diets':
        return Icons.restaurant_menu;
      case 'Reproductive Health':
        return Icons.favorite;
      case 'Create Post':
        return Icons.add_circle;
      default:
        return Icons.grid_view;
    }
  }

  // Get color for category
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Pain Management':
        return Colors.redAccent;
      case 'Exercises':
        return Colors.green;
      case 'Diets':
        return Colors.amber;
      case 'Reproductive Health':
        return Colors.pinkAccent;
      case 'Create Post':
        return Colors.purple;
      default:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove gradient and let the global scaffold background show
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Community',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  // Only notification bell icon, plus sign removed
                  Stack(
                    children: [
                      IconButton(
                        onPressed: _navigateToNotifications,
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Color(0xFFFF5B9D),
                          size: 28,
                        ),
                      ),
                      if (_unreadNotificationCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              _unreadNotificationCount > 9
                                  ? '9+'
                                  : '$_unreadNotificationCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Filter grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3, // 3 items per row
                childAspectRatio: 2.5, // Width to height ratio
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children:
                    filterOptions.map((filter) {
                      final isSelected = selectedFilter == filter;
                      final color = _getCategoryColor(filter);

                      return GestureDetector(
                        onTap: () {
                          if (filter == 'Create Post') {
                            _navigateToCreatePost();
                          } else {
                            setState(() {
                              selectedFilter = filter;
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? color.withOpacity(0.9)
                                    : Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow:
                                isSelected
                                    ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                    : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _getCategoryIcon(filter),
                                color: isSelected ? Colors.white : color,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  filter,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // Posts section
            Expanded(
              child:
                  isLoading
                      ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.pink,
                          ),
                        ),
                      )
                      : _getFilteredPosts().isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 70,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              selectedFilter == 'All'
                                  ? 'No posts yet. Be the first to share!'
                                  : 'No posts in this category yet.',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _navigateToCreatePost,
                              icon: const Icon(Icons.add),
                              label: const Text('Create Post'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink.withOpacity(0.8),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _getFilteredPosts().length,
                        itemBuilder: (context, index) {
                          final post = _getFilteredPosts()[index];
                          return GestureDetector(
                            onTap: () => _navigateToPostDetail(post),
                            child: EnhancedCommunityPostCard(
                              post: post,
                              onPostUpdated:
                                  () => _loadPosts(), // Callback for pin/unpin
                              onPostDeleted:
                                  () => _loadPosts(), // Callback for delete
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced Community Post Card with Pin and Delete Features
class EnhancedCommunityPostCard extends StatefulWidget {
  final CommunityPost post;
  final Function? onPostUpdated; // Callback for post updates
  final Function? onPostDeleted; // Callback for post deletion

  const EnhancedCommunityPostCard({
    super.key,
    required this.post,
    this.onPostUpdated,
    this.onPostDeleted,
  });

  @override
  State<EnhancedCommunityPostCard> createState() =>
      _EnhancedCommunityPostCardState();
}

class _EnhancedCommunityPostCardState extends State<EnhancedCommunityPostCard> {
  final CommunityService _communityService = CommunityService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  // Handle pin post action
  Future<void> _handlePinPost() async {
    try {
      final isPinned = await _communityService.togglePinPost(widget.post.id);

      // Update local state
      setState(() {
        widget.post.isPinned = isPinned;
      });

      // Notify parent widget if callback is provided
      if (widget.onPostUpdated != null) {
        widget.onPostUpdated!();
      }

      // Show snackbar confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isPinned ? 'Post pinned successfully' : 'Post unpinned',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pin post: $e')));
    }
  }

  // Handle delete post action
  Future<void> _handleDeletePost() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Post'),
            content: const Text('Are you sure you want to delete this post?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'DELETE',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _communityService.deletePost(widget.post.id);

        // Notify parent widget if callback is provided
        if (widget.onPostDeleted != null) {
          widget.onPostDeleted!();
        }

        // Show snackbar confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post deleted successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete post: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUserPostAuthor = _auth.currentUser?.uid == widget.post.authorId;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
          // Author info and time
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                // Author avatar
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color:
                        widget.post.isAnonymous
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
                        fontSize: 20,
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
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                // More options button with pin functionality
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onSelected: (String choice) async {
                    if (choice == 'pin') {
                      await _handlePinPost();
                    } else if (choice == 'delete') {
                      await _handleDeletePost();
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    final List<PopupMenuEntry<String>> options = [];

                    // Pin/Unpin option
                    options.add(
                      PopupMenuItem<String>(
                        value: 'pin',
                        child: Row(
                          children: [
                            Icon(
                              widget.post.isPinned
                                  ? Icons.push_pin
                                  : Icons.push_pin_outlined,
                              color:
                                  widget.post.isPinned
                                      ? const Color.fromARGB(255, 240, 99, 153)
                                      : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.post.isPinned ? 'Unpin Post' : 'Pin Post',
                            ),
                          ],
                        ),
                      ),
                    );

                    // Add delete option for post author
                    if (isUserPostAuthor) {
                      options.add(const PopupMenuDivider());
                      options.add(
                        const PopupMenuItem<String>(
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
                        ),
                      );
                    }

                    return options;
                  },
                ),
              ],
            ),
          ),

          // Display pin indicator if post is pinned
          if (widget.post.isPinned)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.push_pin,
                    size: 16,
                    color: const Color.fromARGB(255, 240, 99, 153),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Pinned',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color.fromARGB(255, 240, 99, 153),
                    ),
                  ),
                ],
              ),
            ),

          // Post content - limited to 3 lines with ellipsis
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
          ),

          const SizedBox(height: 12),

          // Image if available
          if (widget.post.imageUrls != null &&
              widget.post.imageUrls!.isNotEmpty)
            Container(
              height: 200,
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
                  children:
                      widget.post.tags.map((tag) {
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
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite_border,
                          size: 20,
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
                    const SizedBox(width: 20),
                    Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 20,
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
