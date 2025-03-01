// lib/services/community-service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/models/community-models.dart';
import '../models/comment.dart';

class CommunityService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  final CollectionReference _postsCollection = FirebaseFirestore.instance
      .collection('posts');
  final CollectionReference _commentsCollection = FirebaseFirestore.instance
      .collection('comments');
  final CollectionReference _likesCollection = FirebaseFirestore.instance
      .collection('likes');

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get all posts
  Stream<List<CommunityPost>> getPosts() {
    return _postsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // Ensure id is included in the data
            data['id'] = doc.id;
            return CommunityPost.fromMap(data);
          }).toList();
        });
  }

  // Get posts by tag
  Stream<List<CommunityPost>> getPostsByTag(String tag) {
    return _postsCollection
        .where('tags', arrayContains: tag)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // Ensure id is included in the data
            data['id'] = doc.id;
            return CommunityPost.fromMap(data);
          }).toList();
        });
  }

  // Get posts by user
  Stream<List<CommunityPost>> getPostsByUser(String userId) {
    return _postsCollection
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            // Ensure id is included in the data
            data['id'] = doc.id;
            return CommunityPost.fromMap(data);
          }).toList();
        });
  }

  // Add new post
  Future<String> addPost({
    required String content,
    required List<String> tags,
    List<String>? images,
    bool isAnonymous = false,
  }) async {
    // Check if user is authenticated
    final user = currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    // Create post document
    final newPost = CommunityPost(
      id: '', // Will be updated with document ID
      authorId: user.uid,
      authorName: isAnonymous ? 'Anonymous' : user.displayName ?? 'User',
      authorAvatar: user.photoURL ?? '',
      createdAt: DateTime.now(),
      content: content,
      tags: tags,
      likeCount: 0,
      commentCount: 0,
      imageUrls: images,
      isAnonymous: isAnonymous,
    );

    // Convert to map and update createdAt to Timestamp for Firestore
    final Map<String, dynamic> postData = newPost.toMap();
    postData['createdAt'] = Timestamp.fromDate(newPost.createdAt);

    // Add to Firestore
    final docRef = await _postsCollection.add(postData);

    // Update the post with the document ID
    await docRef.update({'id': docRef.id});

    return docRef.id;
  }

  // Check if user has liked a post
  Future<bool> hasUserLikedPost(String postId, String userId) async {
    if (userId == 'anonymous') return false;

    final likeDoc =
        await _likesCollection
            .where('postId', isEqualTo: postId)
            .where('userId', isEqualTo: userId)
            .get();

    return likeDoc.docs.isNotEmpty;
  }

  // Like a post
  Future<void> likePost(String postId, String userId) async {
    // Check if user is authenticated
    if (userId == 'anonymous') {
      throw Exception('You need to be logged in to like a post');
    }

    // Check if user already liked this post
    final likeDoc =
        await _likesCollection
            .where('postId', isEqualTo: postId)
            .where('userId', isEqualTo: userId)
            .get();

    if (likeDoc.docs.isEmpty) {
      // User hasn't liked this post yet, add like
      await _likesCollection.add({
        'postId': postId,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Increment like count
      await _postsCollection.doc(postId).update({
        'likeCount': FieldValue.increment(1),
      });
    } else {
      // User already liked this post, remove like
      await _likesCollection.doc(likeDoc.docs.first.id).delete();

      // Decrement like count
      await _postsCollection.doc(postId).update({
        'likeCount': FieldValue.increment(-1),
      });
    }
  }

  // Get comments for a post
  Future<List<Comment>> getCommentsForPost(String postId) async {
    final snapshot =
        await _commentsCollection
            .where('postId', isEqualTo: postId)
            .orderBy('createdAt', descending: false)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      // Ensure id is included in the data
      data['id'] = doc.id;
      return Comment.fromMap(data);
    }).toList();
  }

  // Add a comment
  Future<void> addComment(Comment comment) async {
    // Convert to map and update createdAt to Timestamp for Firestore
    final Map<String, dynamic> commentData = comment.toMap();
    commentData['createdAt'] = Timestamp.fromDate(comment.createdAt);

    // Add comment to Firestore
    final docRef = await _commentsCollection.add(commentData);

    // Update the comment with the document ID
    await docRef.update({'id': docRef.id});

    // Increment comment count on the post
    await _postsCollection.doc(comment.postId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  // Delete a post
  Future<void> deletePost(String postId) async {
    // Delete all comments for this post
    final commentDocs =
        await _commentsCollection.where('postId', isEqualTo: postId).get();

    for (var doc in commentDocs.docs) {
      await _commentsCollection.doc(doc.id).delete();
    }

    // Delete all likes for this post
    final likeDocs =
        await _likesCollection.where('postId', isEqualTo: postId).get();

    for (var doc in likeDocs.docs) {
      await _likesCollection.doc(doc.id).delete();
    }

    // Delete the post itself
    await _postsCollection.doc(postId).delete();
  }

  // Delete a comment
  Future<void> deleteComment(String commentId, String postId) async {
    // Delete the comment
    await _commentsCollection.doc(commentId).delete();

    // Decrement comment count on the post
    await _postsCollection.doc(postId).update({
      'commentCount': FieldValue.increment(-1),
    });
  }

  // Get all available tags
  Future<List<String>> getAllTags() async {
    final snapshot = await _postsCollection.get();

    // Collect all tags from all posts
    final Set<String> allTags = {};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('tags')) {
        final tags = List<String>.from(data['tags']);
        allTags.addAll(tags);
      }
    }

    return allTags.toList();
  }
}
