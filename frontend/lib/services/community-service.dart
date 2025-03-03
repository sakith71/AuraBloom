// lib/services/community-service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/community-models.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user display name or email - more robust implementation
  String getUserDisplayName() {
    final User? user = _auth.currentUser;

    if (user == null) {
      return 'Unknown';
    }

    // First try display name
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }

    // Then try email
    if (user.email != null && user.email!.isNotEmpty) {
      return user.email!;
    }

    // Finally fall back to UID if everything else is unavailable
    return user.uid.substring(0, 8); // Use first part of UID as fallback
  }

  // Stream of posts
  Stream<List<CommunityPost>> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return CommunityPost.fromMap(data);
          }).toList();
        });
  }

  // Add a new post with better logging and error handling
  Future<void> addPost({
    required String content,
    required List<String> tags,
    List<String>? images,
    bool isAnonymous = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Log user info for debugging
    if (kDebugMode) {
      print('Current user: ${user.uid}');
      print('Display name: ${user.displayName}');
      print('Email: ${user.email}');
    }

    // Get user display name or email with improved logic
    String authorName;
    if (isAnonymous) {
      authorName = 'Anonymous';
    } else if (user.displayName != null && user.displayName!.isNotEmpty) {
      authorName = user.displayName!;
    } else if (user.email != null && user.email!.isNotEmpty) {
      authorName = user.email!;
    } else {
      authorName =
          'User_${user.uid.substring(0, 5)}'; // Fallback with part of UID
    }

    // Create post data
    final post = {
      'authorId': user.uid,
      'authorName': authorName,
      'authorAvatar': user.photoURL ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'content': content,
      'tags': tags,
      'likeCount': 0,
      'commentCount': 0,
      'imageUrls': images,
      'isAnonymous': isAnonymous,
    };

    // Log post data for debugging
    if (kDebugMode) {
      print('Creating post with author name: ${post['authorName']}');
    }

    // Add to Firestore
    await _firestore.collection('posts').add(post);
  }

  // Get a specific post
  Future<CommunityPost?> getPost(String postId) async {
    final doc = await _firestore.collection('posts').doc(postId).get();
    if (!doc.exists) {
      return null;
    }
    final data = doc.data();
    data?['id'] = doc.id;
    return CommunityPost.fromMap(data!);
  }

  // Like a post
  Future<void> likePost(String postId, String userId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Check if user already liked the post
    final likeDoc =
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('likes')
            .doc(userId)
            .get();

    if (likeDoc.exists) {
      // User already liked the post, so unlike it
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(userId)
          .delete();

      // Decrement like count
      await _firestore.collection('posts').doc(postId).update({
        'likeCount': FieldValue.increment(-1),
      });
    } else {
      // User hasn't liked the post, so like it
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('likes')
          .doc(userId)
          .set({'userId': userId, 'timestamp': FieldValue.serverTimestamp()});

      // Increment like count
      await _firestore.collection('posts').doc(postId).update({
        'likeCount': FieldValue.increment(1),
      });
    }
  }

  // Check if user liked a post
  Future<bool> hasUserLikedPost(String postId, String userId) async {
    final likeDoc =
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('likes')
            .doc(userId)
            .get();

    return likeDoc.exists;
  }

  // Add comment to post with improved user name handling
  Future<void> addComment(Comment comment) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Create comment data with explicit author name handling
    Map<String, dynamic> commentData = comment.toMap();

    // Override with current user info to ensure latest data
    if (!comment.isAnonymous) {
      String authorName;
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        authorName = user.displayName!;
      } else if (user.email != null && user.email!.isNotEmpty) {
        authorName = user.email!;
      } else {
        authorName = 'User_${user.uid.substring(0, 5)}';
      }
      commentData['authorName'] = authorName;
    }

    commentData['createdAt'] = FieldValue.serverTimestamp();

    // Log for debugging
    if (kDebugMode) {
      print('Adding comment with author name: ${commentData['authorName']}');
    }

    // Add to post's comments collection
    await _firestore
        .collection('posts')
        .doc(comment.postId)
        .collection('comments')
        .add(commentData);

    // Increment comment count
    await _firestore.collection('posts').doc(comment.postId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  // Get comments for a post
  Future<List<Comment>> getCommentsForPost(String postId) async {
    final snapshot =
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .orderBy('createdAt', descending: false)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      data['postId'] = postId;
      return Comment.fromMap(data);
    }).toList();
  }

  // Delete a comment
  Future<void> deleteComment(String commentId, String postId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Delete the comment
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();

    // Decrement comment count
    await _firestore.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(-1),
    });
  }

  // Delete a post
  Future<void> deletePost(String postId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Check if the user is the author of the post
    final post = await getPost(postId);
    if (post == null) {
      throw Exception('Post not found');
    }

    if (post.authorId != user.uid) {
      throw Exception('User is not authorized to delete this post');
    }

    // Delete the post
    await _firestore.collection('posts').doc(postId).delete();
  }
}
