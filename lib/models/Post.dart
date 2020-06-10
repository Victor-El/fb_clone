import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fb_clone/models/Comment.dart';
import 'package:flutter/material.dart';

class Post {
  String email;
  String id;
  String imageUrl;
  String postContent;
  Timestamp timestamp;
  List<String> likes;
  List<Comment> comments;

  static const List<Comment> sComments = <Comment>[];
  static const List<String> sLikes = <String>[];

  Post(this.email, this.id, this.imageUrl, this.postContent, this.timestamp, this.likes,
      this.comments);

  Post.construct({
    @required this.email,
    @required this.id,
    @required this.imageUrl,
    @required this.postContent,
    @required this.timestamp,
    this.likes = sLikes,
    this.comments = sComments,
  });

  Post.fromMap(Map<String, dynamic> postMap) {
    this.id = postMap['user-id'];
    this.imageUrl = postMap['image-url'];
    this.postContent = postMap['post-content'];
    this.timestamp = postMap['timestamp'];
    this.likes = postMap['likes'];
    this.comments = postMap['comments'];
  }

  Map<String, dynamic> toMap() => {
        "user-id": this.id,
        "image-url": this.imageUrl,
        "post-content": this.postContent,
        "timestamp": this.timestamp,
        "likes": this.likes,
        "comments": this.comments,
      };
}
