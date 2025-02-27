import 'package:flutter/material.dart';

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

  final List<PostModel> posts = [
    PostModel(
      username: 'Alice',
      date: 'Feb 20',
      tags: ['Pain Management'],
      likes: 12,
      comments: 3,
    ),
    PostModel(
      username: 'Sara',
      date: 'Feb 21',
      tags: ['Exercises'],
      likes: 8,
      comments: 2,
    ),
    PostModel(
      username: 'Clara',
      date: 'Feb 22',
      tags: ['Diets'],
      likes: 20,
      comments: 5,
    ),
    PostModel(
      username: 'Emma',
      date: 'Feb 23',
      tags: ['Reproductive Health'],
      likes: 15,
      comments: 7,
    ),
  ];

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
              alignment: Alignment.centerLeft, // Align to the left
              child: const Text(
                'Community',
                style: TextStyle(
                  color: Colors.black, // Black color instead of pink
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Use Wrap for filter tabs to allow automatic line wrapping
            Wrap(
              spacing: 10.0, // Horizontal spacing between items
              runSpacing: 10.0, // Vertical spacing between rows
              children:
                  filterOptions.map((filter) {
                    // Icons for each tab
                    IconData icon;
                    switch (filter) {
                      case 'Pain Management':
                        icon = Icons.health_and_safety; // Health icon
                        break;
                      case 'Exercises':
                        icon = Icons.fitness_center; // Exercise icon
                        break;
                      case 'Diets':
                        icon = Icons.restaurant_menu; // Diet icon
                        break;
                      case 'Reproductive Health':
                        icon = Icons.spa; // Reproductive Health icon
                        break;
                      case 'Create Post':
                        icon = Icons.add_circle; // Add new post icon
                        break;
                      default:
                        icon = Icons.all_inclusive; // Default icon for "All"
                    }

                    return GestureDetector(
                      onTap: () {
                        if (filter == 'Create Post') {
                          // Here you would add logic to open post creation screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Create post functionality coming soon!',
                              ),
                            ),
                          );
                        } else {
                          setState(() {
                            selectedFilter = filter;
                          });
                        }
                      },
                      child: Chip(
                        backgroundColor:
                            selectedFilter == filter
                                ? Colors.pink.withOpacity(
                                  0.5,
                                ) // Lighter pink background
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

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  if (selectedFilter != 'All' &&
                      !post.tags.contains(selectedFilter)) {
                    return const SizedBox.shrink();
                  }
                  return PostCard(post: post);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostModel {
  final String username;
  final String date;
  final List<String> tags;
  final int likes;
  final int comments;

  PostModel({
    required this.username,
    required this.date,
    required this.tags,
    required this.likes,
    required this.comments,
  });
}

class PostCard extends StatelessWidget {
  final PostModel post;
  const PostCard({Key? key, required this.post}) : super(key: key);

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
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.pinkAccent,
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      post.date,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Placeholder image related to menstrual cycle
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.pink.withOpacity(
                  0.1,
                ), // Lighter pink color for container
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/period_icon.png',
                  ), // Add a relevant image
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(Icons.favorite_border, size: 20, color: Colors.pink),
                const SizedBox(width: 4),
                Text(
                  '${post.likes} Likes',
                  style: const TextStyle(color: Colors.pink),
                ),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, size: 20, color: Colors.pink),
                const SizedBox(width: 4),
                Text(
                  '${post.comments} Comments',
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
