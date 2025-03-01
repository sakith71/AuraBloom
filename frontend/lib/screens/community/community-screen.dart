import 'package:flutter/material.dart';
import 'package:frontend/models/community-models.dart';
import 'package:frontend/screens/community/post-detail-screen.dart';
import 'package:frontend/screens/create_post_screen.dart';

import 'package:frontend/services/community-service.dart';

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
  List<CommunityPost> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Listen to the stream of posts
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

  List<CommunityPost> _getFilteredPosts() {
    if (selectedFilter == 'All') {
      return posts;
    } else {
      return posts.where((post) => post.tags.contains(selectedFilter)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF4C2CA), // Light Pink
              Color(0xFFD4C0D6), // Light Purple
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Community',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Filter tabs with Wrap for automatic wrapping
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 10.0,
                runSpacing: 10.0,
                children:
                    filterOptions.map((filter) {
                      // Icons for each tab
                      IconData icon;
                      switch (filter) {
                        case 'Pain Management':
                          icon = Icons.health_and_safety;
                          break;
                        case 'Exercises':
                          icon = Icons.fitness_center;
                          break;
                        case 'Diets':
                          icon = Icons.restaurant_menu;
                          break;
                        case 'Reproductive Health':
                          icon = Icons.spa;
                          break;
                        case 'Create Post':
                          icon = Icons.add_circle;
                          break;
                        default:
                          icon = Icons.all_inclusive;
                      }

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
                        child: Chip(
                          backgroundColor:
                              selectedFilter == filter
                                  ? Colors.pink.withOpacity(0.5)
                                  : Colors.white,
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icon,
                                color:
                                    selectedFilter == filter
                                        ? Colors.white
                                        : Colors.black,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                filter,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      selectedFilter == filter
                                          ? Colors.white
                                          : Colors.black,
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
                      ? const Center(child: CircularProgressIndicator())
                      : _getFilteredPosts().isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 60,
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
                                backgroundColor: Colors.pink.withOpacity(0.7),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
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
                            child: CommunityPostCard(post: post),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreatePost,
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class CommunityPostCard extends StatelessWidget {
  final CommunityPost post;
  const CommunityPostCard({Key? key, required this.post}) : super(key: key);

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
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      post.isAnonymous ? Colors.grey : Colors.pinkAccent,
                  radius: 20,
                  child: Text(
                    post.isAnonymous
                        ? 'A'
                        : (post.authorName.isNotEmpty
                            ? post.authorName[0]
                            : 'U'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.isAnonymous ? 'Anonymous' : post.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _formatDate(post.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                // Tags as chips
                Wrap(
                  spacing: 4,
                  children:
                      post.tags.map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.blue,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                        );
                      }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Post content - limited to 3 lines with ellipsis
            Text(
              post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 12),

            // Image if available
            if (post.imageUrls != null && post.imageUrls!.isNotEmpty)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.pink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(post.imageUrls![0]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Likes and comments count
            Row(
              children: [
                Icon(Icons.favorite_border, size: 20, color: Colors.pink),
                const SizedBox(width: 4),
                Text(
                  '${post.likeCount} Likes',
                  style: const TextStyle(color: Colors.pink),
                ),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, size: 20, color: Colors.pink),
                const SizedBox(width: 4),
                Text(
                  '${post.commentCount} Comments',
                  style: const TextStyle(color: Colors.pink),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
