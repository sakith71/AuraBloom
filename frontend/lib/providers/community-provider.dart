import 'package:flutter/material.dart';

class PostModel {
  final String username;
  final String date;
  final List<String> tags;
  final int likes;
  final int comments;
  final String content;
  final bool isAnonymous;

  PostModel({
    required this.username,
    required this.date,
    required this.tags,
    required this.likes,
    required this.comments,
    required this.content,
    this.isAnonymous = false,
  });
}

class CommunityProvider extends ChangeNotifier {
  final List<PostModel> _posts = [];

  List<PostModel> get posts => _posts;

  void addPost(String content, bool isAnonymous) {
    _posts.add(
      PostModel(
        username: isAnonymous ? 'Anonymous' : 'User',
        date: 'Just now',
        tags: [],
        likes: 0,
        comments: 0,
        content: content,
        isAnonymous: isAnonymous,
      ),
    );
    notifyListeners();
  }
}
