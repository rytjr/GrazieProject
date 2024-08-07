import 'package:dio/dio.dart';

import 'package:fluttertest/Post.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://jsonplaceholder.typicode.com/'));

  Future<List<Post>> getPosts() async {
    try {
      Response response = await _dio.get('posts');
      List<dynamic> data = response.data;
      return data.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}
