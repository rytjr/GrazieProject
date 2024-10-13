import 'package:flutter/material.dart';
import 'package:fluttertest/CouponScreen.dart';
import 'package:fluttertest/NicknameScreen.dart';
import 'package:fluttertest/SecureStorageService.dart';
import 'package:fluttertest/UserInfoChangeScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON 파싱을 위해 추가

class MyPageScreen extends StatefulWidget {
  @override
  _MyPageScreenState createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  Future<String> fetchUserName() async {
    // 서버에서 사용자 정보 가져오기
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();

    final response = await http.get(
      Uri.parse('http://34.64.110.210:8080/users/readProflie'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['name']; // 서버에서 반환된 name 값
    } else {
      throw Exception('Failed to load user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마이페이지'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 기능
          },
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              // 사용자 이름을 서버로부터 받아와 동적으로 표시
              child: FutureBuilder<String>(
                future: fetchUserName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // 데이터 로딩 중
                  } else if (snapshot.hasError) {
                    return Text('오류가 발생했습니다.');
                  } else if (snapshot.hasData) {
                    return Text(
                      '${snapshot.data} 님',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    );
                  } else {
                    return Text('사용자 정보를 불러올 수 없습니다.');
                  }
                },
              ),
            ),
            SizedBox(height: 30),
            ListTile(
              title: Text('닉네임'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NicknameScreen()), // 닉네임 화면으로 이동
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text('회원정보 수정'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserInfoChangeScreen()), // 회원정보 수정 화면으로 이동
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text('쿠폰'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CouponScreen()), // 쿠폰 화면으로 이동
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
