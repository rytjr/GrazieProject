import 'package:dio/dio.dart';
import 'package:dio/dio.dart';  // Dio 패키지 import
import 'package:fluttertest/Post.dart';
import 'package:fluttertest/MenuItem.dart';

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


/*class ApiService {
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

  // 서버에서 추천 메뉴 데이터를 가져오는 메서드 (GET 요청)
  Future<List<MenuItem>?> fetchRecommendedMenu() async {
    try {
      Response response = await _dio.get('recommended-menu'); // 추천 메뉴 엔드포인트
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => MenuItem.fromJson(item)).toList();
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}*/


/*class ApiService {
  final Dio dio = Dio();

  ApiClient() {
    dio.options.baseUrl = 'http://10.0.2.2:8000/'; // 서버 주소
  }

  // 메뉴 목록 가져오기
  Future<List<MenuItem>> fetchMenuItems() async {
    try {
      final response = await dio.get('/menu');
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((item) => MenuItem.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load menu');
      }
    } on DioError catch (e) {
      throw Exception('Failed to load menu: ${e.message}');
    }
  }
}*/


import 'package:dio/dio.dart' as dio;

class ApiService {
  final dio.Dio dioInstance = dio.Dio();

  Future<dio.Response> getRequest(String url, {Map<String, dynamic>? headers}) async {
    try {
      return await dioInstance.get(url, options: dio.Options(headers: headers));
    } catch (e) {
      throw Exception('Failed to load data');
    }
  }

  Future<dio.Response> postRequest(String url, Map<String, dynamic> data, {Map<String, dynamic>? headers}) async {
    try {
      return await dioInstance.post(url, data: data, options: dio.Options(headers: headers));
    } catch (e) {
      throw Exception('Failed to send data');
    }
  }
}




