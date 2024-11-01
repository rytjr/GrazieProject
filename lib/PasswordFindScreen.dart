import 'dart:convert'; // JSON 파싱을 위해 추가
import 'package:flutter/material.dart';
import 'package:fluttertest/LoginScreen.dart';
import 'package:fluttertest/IdFindScreen.dart';
import 'package:fluttertest/UserInScreen.dart';
import 'package:http/http.dart' as http;

class PasswordFindScreen extends StatefulWidget {
  @override
  _PasswordFindScreenState createState() => _PasswordFindScreenState();
}

class _PasswordFindScreenState extends State<PasswordFindScreen> {
  final TextEditingController _emailController = TextEditingController(); // 이메일 입력값을 제어하는 컨트롤러
  final TextEditingController _idController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            _buildInputField('아이디', _idController),
            SizedBox(height: 20),
            _buildInputField('이메일', _emailController),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await _sendNewPassword(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5B1333),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('비밀번호 찾기', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            SizedBox(height: 10),
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
                            builder: (context) => IdFindScreen()),
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

  Widget _buildInputField(String labelText, TextEditingController controller) {
    return TextField(
      controller: controller, // 컨트롤러 연결
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
    String email = _emailController.text; // 이메일 값 가져오기
    String id = _idController.text; // 아이디 값 가져오기

    if (email.isEmpty) {
      _showErrorDialog('이메일을 입력해주세요.');
      return;
    }
    final response = await http.post(
      Uri.parse('http://34.64.110.210:8080/email/request-temp-password'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"userId" : id, "email": email}), // 사용자가 입력한 이메일을 JSON body에 포함
    );

    print("비밀번호 찾기 응답 상태: ${response.statusCode}");
    print("비밀번호 찾기 응답 본문: ${response.body}");
    print("전달된 아이디: $id");
    print("전달된 이메일: $email");

    if (response.statusCode == 200) {
      _showSuccessDialog(context); // 성공 메시지 모달 표시
    } else {
      _showErrorDialog('아이디, 이메일을 확인해 주세요.');
    }
  }

  // 성공 메시지 모달 창 표시
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('알림'),
          content: Text('임시 비밀번호가 이메일로 발송되었습니다.'),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // 오류 메시지 모달 창 표시
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

void main() => runApp(MaterialApp(
  home: PasswordFindScreen(),
));
