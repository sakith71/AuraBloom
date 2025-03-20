import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/models/comment.dart';
import 'package:frontend/models/community-models.dart';
import 'package:frontend/models/notification.dart';
import 'package:frontend/models/reply.dart';
import 'package:frontend/services/notification-service.dart';

class CommunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

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

    // First, get the post to find the post author
    final post = await getPost(postId);
    if (post == null) {
      throw Exception('Post not found');
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

      // Create notification for post author
      await _notificationService.createNotification(
        userId: post.authorId,
        postId: postId,
        type: NotificationType.like,
      );
    }
  }

    // Toggle pin status of a post
  Future<bool> togglePinPost(String postId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Get the current post
    final postDoc = await _firestore.collection('posts').doc(postId).get();
    if (!postDoc.exists) {
      throw Exception('Post not found');
    }

    final data = postDoc.data() as Map<String, dynamic>;
    final bool currentlyPinned = data['isPinned'] ?? false;
    
    // Toggle the pinned status
    await _firestore.collection('posts').doc(postId).update({
      'isPinned': !currentlyPinned,
    });
    
    return !currentlyPinned; // Return the new pinned status
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

    // Get the post to find the post author
    final post = await getPost(comment.postId);
    if (post == null) {
      throw Exception('Post not found');
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
    commentData['replyCount'] = 0; // Initialize reply count

    // Log for debugging
    if (kDebugMode) {
      print('Adding comment with author name: ${commentData['authorName']}');
    }

    // Add to post's comments collection
    final docRef = await _firestore
        .collection('posts')
        .doc(comment.postId)
        .collection('comments')
        .add(commentData);

    // Increment comment count
    await _firestore.collection('posts').doc(comment.postId).update({
      'commentCount': FieldValue.increment(1),
    });

    // Create notification for post author
    await _notificationService.createNotification(
      userId: post.authorId,
      postId: comment.postId,
      commentId: docRef.id,
      content: comment.content,
      type: NotificationType.comment,
    );
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

    // Delete all replies to the comment
    final repliesSnapshot =
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .get();

    final batch = _firestore.batch();

    for (var doc in repliesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Delete the comment
    batch.delete(
      _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId),
    );

    await batch.commit();

    // Decrement comment count
    await _firestore.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(-1),
    });
  }

  // Add reply to a comment
  Future<void> addReply(Reply reply) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Create reply data
    Map<String, dynamic> replyData = reply.toMap();

    // Override with current user info to ensure latest data
    if (!reply.isAnonymous) {
      String authorName;
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        authorName = user.displayName!;
      } else if (user.email != null && user.email!.isNotEmpty) {
        authorName = user.email!;
      } else {
        authorName = 'User_${user.uid.substring(0, 5)}';
      }
      replyData['authorName'] = authorName;
    }

    replyData['createdAt'] = FieldValue.serverTimestamp();

    // Log for debugging
    if (kDebugMode) {
      print('Adding reply with author name: ${replyData['authorName']}');
    }

    // Get the post ID for the comment
    final commentSnapshot =
        await _firestore
            .collection('posts')
            .where('comments', arrayContains: reply.commentId)
            .limit(1)
            .get();

    String postId = '';
    if (commentSnapshot.docs.isNotEmpty) {
      postId = commentSnapshot.docs.first.id;
    } else {
      // Find the post ID by querying all posts
      final allPostsSnapshot = await _firestore.collection('posts').get();
      for (final doc in allPostsSnapshot.docs) {
        final commentCheck =
            await doc.reference
                .collection('comments')
                .doc(reply.commentId)
                .get();
        if (commentCheck.exists) {
          postId = doc.id;
          break;
        }
      }
    }

    if (postId.isEmpty) {
      throw Exception('Could not find post for this comment');
    }

    // Get the comment to find its author
    final commentDoc =
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(reply.commentId)
            .get();

    if (!commentDoc.exists) {
      throw Exception('Comment not found');
    }

    final commentData = commentDoc.data() as Map<String, dynamic>;
    final commentAuthorId = commentData['authorId'];

    // Add to comment's replies collection
    final replyDocRef = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(reply.commentId)
        .collection('replies')
        .add(replyData);

    // Increment reply count on the comment
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(reply.commentId)
        .update({'replyCount': FieldValue.increment(1)});

    // Create notification for comment author
    await _notificationService.createNotification(
      userId: commentAuthorId,
      postId: postId,
      commentId: reply.commentId,
      replyId: replyDocRef.id,
      content: reply.content,
      type: NotificationType.reply,
    );
  }

  // Get replies for a comment
  Future<List<Reply>> getRepliesForComment(
    String postId,
    String commentId,
  ) async {
    final snapshot =
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .collection('replies')
            .orderBy('createdAt', descending: false)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      data['commentId'] = commentId;
      return Reply.fromMap(data);
    }).toList();
  }

  // Delete a reply
  Future<void> deleteReply(
    String postId,
    String commentId,
    String replyId,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Delete the reply
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .doc(replyId)
        .delete();

    // Decrement reply count
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .update({'replyCount': FieldValue.increment(-1)});
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
