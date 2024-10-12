import 'dart:convert'; // JSON 파싱을 위해 추가
import 'package:flutter/material.dart';
import 'package:fluttertest/LoginScreen.dart';
import 'package:fluttertest/SecureStorageService.dart';
import 'package:fluttertest/UserInScreen.dart';
import 'package:http/http.dart' as http;

class PasswordFindScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('비밀번호 찾기'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0, // 그림자 제거
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            _buildInputField('아이디'),
            SizedBox(height: 20),
            _buildInputField('이름'),
            SizedBox(height: 20),
            _buildInputField('이메일'),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await _sendNewPassword(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00C853), // 버튼 색상 (녹색)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('비밀번호 찾기'),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text('로그인'),
                  ),
                  Text('/'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PasswordFindScreen()),
                      );
                    },
                    child: Text('아이디 찾기'),
                  ),
                  Text('/'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserInScreen()),
                      );
                    },
                    child: Text('회원가입'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String labelText) {
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.grey),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey), // 기본 테두리 선 색상
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black), // 포커스 시 테두리 선 색상
        ),
      ),
    );
  }

  // 비밀번호 변경 요청
  Future<void> _sendNewPassword(BuildContext context) async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();

    final response = await http.post(
      Uri.parse('http://localhost:8080/users/changeTempPassword?token=$token'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // 서버로부터 반환된 JSON 데이터에서 비밀번호를 추출
      final Map<String, dynamic> responseData = json.decode(response.body);
      final newPassword = responseData['newPassword']; // 서버에서 반환된 비밀번호

      // 모달 창에 새 비밀번호를 표시하고 확인을 누르면 로그인 화면으로 이동
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('새 비밀번호'),
            content: Text('새 비밀번호: $newPassword'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비밀번호 변경에 실패했습니다.')),
      );
    }
  }
}

void main() => runApp(MaterialApp(
  home: PasswordFindScreen(),
));
