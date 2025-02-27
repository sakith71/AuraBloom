import 'package:flutter/material.dart';
import '../providers/community_provider.dart';

class PostWidget extends StatelessWidget {
  final PostModel post;

  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.pinkAccent,
                  radius: 18,
                  child: Text(
                    post.isAnonymous ? 'A' : post.username[0],
                    style: const TextStyle(color: Colors.white),
                  ),
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
            Text(post.content, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            // Tags (if available)
            if (post.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                children:
                    post.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
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
            // Likes and Comments
            Row(
              children: [
                Icon(Icons.favorite_border, size: 18, color: Colors.grey[700]),
                const SizedBox(width: 4),
                Text('${post.likes} Likes'),
                const SizedBox(width: 16),
                Icon(
                  Icons.chat_bubble_outline,
                  size: 18,
                  color: Colors.grey[700],
                ),
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
