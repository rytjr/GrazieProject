import 'package:flutter/material.dart';
import 'package:fluttertest/SecureStorageService.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserInfoChangeScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<UserInfoChangeScreen> {
  Map<String, dynamic> userProfile = {}; // 사용자 정보 저장

  @override
  void initState() {
    super.initState();
    fetchUserProfile(); // 사용자 정보 가져오기
  }

  // 사용자 정보 가져오기
  Future<void> fetchUserProfile() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    final response = await http.get(
      Uri.parse('http://34.64.110.210:8080/users/readProfile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final decodedResponseBody = utf8.decode(response.bodyBytes);
    if (response.statusCode == 200) {
      setState(() {
        userProfile = jsonDecode(decodedResponseBody);
      });
    } else {
      throw Exception('Failed to load profile');
    }
  }

  // 사용자 정보 수정 요청 보내기
  Future<void> updateUserProfile() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    try {
      final response = await http.put(
        Uri.parse('http://34.64.110.210:8080/users/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(userProfile),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정이 완료되었습니다.')),
        );
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수정 중 오류가 발생했습니다: $e')),
      );
    }
  }

  // 회원탈퇴 요청 보내기
  Future<void> deleteUserAccount() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    try {
      final response = await http.delete(
        Uri.parse('http://34.64.110.210:8080/users/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('탈퇴 ${response.body}');
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원탈퇴가 완료되었습니다.')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to delete account');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원탈퇴 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,

        title: Text('회원정보 수정'),
        centerTitle: true, // 타이틀 중앙 정렬
      ),

      body: userProfile.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView( // 스크롤 가능하도록 SingleChildScrollView 추가
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text('이름'),
            Text(userProfile['name'] ?? ''),
            Divider(),
            Text('전화번호'),
            Text(userProfile['phone'] ?? ''),
            Divider(),
            Text('닉네임'),
            Text(userProfile['nickname'] ?? ''),
            Divider(),
            Text('휴대폰'),
            Text(userProfile['phone'] ?? ''),
            Divider(),
            SizedBox(height: 20),
            Text('추가정보', style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              onChanged: (value) => userProfile['email'] = value,
              decoration: InputDecoration(labelText: '이메일'),
              controller: TextEditingController(text: userProfile['email']),
            ),
            TextField(
              onChanged: (value) => userProfile['gender'] = value,
              decoration: InputDecoration(labelText: '성별'),
              controller: TextEditingController(text: userProfile['gender']),
            ),
            SizedBox(height: 130),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                onPressed: () {
                deleteUserAccount(); // 회원탈퇴 요청
                },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Color(0xFF5B1333),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30), // 동일한 패딩 적용
                    minimumSize: Size(0, 48), // 높이 48 설정 (원하는 크기로 조정 가능)
                  ),
                  child: Text('회원탈퇴', style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: () {
                    updateUserProfile(); // 수정 완료 요청
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5B1333),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30), // 동일한 패딩 적용
                    minimumSize: Size(0, 48), // 높이 48 설정
                  ),
                  child: Text('수정완료', style: TextStyle(color: Colors.white)),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UserInfoChangeScreen(),
  ));
}
