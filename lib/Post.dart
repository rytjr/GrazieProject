import 'package:flutter/material.dart';
import 'package:dio/dio.dart';  // Dio 패키지 사용

/*class Post {
  final int userId;
  final int id;
  final String title;
  final String body;
  final String imageUrl;

  Post({required this.userId, required this.id, required this.title, required this.body, required this.imageUrl});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
      imageUrl: json['imageUrl'],
    );
  }
  // Post 객체를 JSON으로 변환 (필요 시 사용)
  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
    };
  }
}
*/
class Post {
  final List<String> imageUrls;

  Post({required this.imageUrls});

  // JSON 데이터를 Post 객체로 변환
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      imageUrls: List<String>.from(json['imageUrls']),
    );
  }
}
