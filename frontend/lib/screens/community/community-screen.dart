import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  _CommunityScreenState createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String selectedFilter = 'All';
  final List<String> filterOptions = ['All', 'Pain Management', 'Exercises', 'Diets'];
  
  final List<PostModel> posts = [
    PostModel(
      username: 'Kiyara Fero',
      date: '12 Nov 2023',
      tags: ['Exercises', 'Diets'],
      likes: 14,
      comments: 3,
    ),
    PostModel(
      username: 'Trisha G.',
      date: '2h ago',
      tags: ['Pain Management', 'Diets'],
      likes: 10,
      comments: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8D7E6), // Light pink background
      appBar: AppBar(
        title: const Text(
          'Community',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFF8D7E6),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to create post screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Add New Post',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filterOptions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = filterOptions[index];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selectedFilter == filterOptions[index] 
                              ? Colors.black12 
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          filterOptions[index],
                          style: TextStyle(
                            fontWeight: selectedFilter == filterOptions[index] 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Posts
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                
                // Apply filter
                if (selectedFilter != 'All' && !post.tags.contains(selectedFilter)) {
                  return const SizedBox.shrink();
                }
                
                return PostCard(post: post);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final PostModel post;
  
  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.pinkAccent,
                  radius: 18,
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
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Post content placeholder
            Container(
              height: 100,
              width: double.infinity,
              color: Colors.grey[200],
            ),
            
            const SizedBox(height: 12),
            
            // Tags
            Wrap(
              spacing: 8,
              children: post.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 12),
            
            // Likes and comments
            Row(
              children: [
                Icon(Icons.favorite_border, size: 18, color: Colors.grey[700]),
                const SizedBox(width: 4),
                Text('${post.likes} Likes'),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline, size: 18, color: Colors.grey[700]),
                const SizedBox(width: 4),
                Text('${post.comments} Comments'),
              ],
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