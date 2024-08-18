import 'package:dio/dio.dart';

import 'package:fluttertest/Post.dart';

/*class ApiService {   //처음 알려준거 밑에는 로컬에 연습
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
}*/


class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/')); // 로컬 서버 주소 (에뮬레이터에서 localhost 접근 시 10.0.2.2 사용)

  // 서버에서 Post 데이터를 가져오는 메서드 (GET 요청)
  Future<Post?> fetchImageUrls() async {
    try {
      Response response = await _dio.get('image-url'); // 서버 엔드포인트
      if (response.statusCode == 200) {
        return Post.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}


