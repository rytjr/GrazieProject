import 'dart:convert'; // JSON 파싱을 위해 추가
import 'package:flutter/material.dart';
import 'package:fluttertest/LoginScreen.dart';
import 'package:fluttertest/IdFindScreen.dart';
import 'package:fluttertest/SecureStorageService.dart';
import 'package:fluttertest/UserInScreen.dart';
import 'package:http/http.dart' as http;

class PasswordFindScreen extends StatefulWidget {
  @override
  _PasswordFindScreenState createState() => _PasswordFindScreenState();
}

class _PasswordFindScreenState extends State<PasswordFindScreen> {
  final TextEditingController _emailController = TextEditingController(); // 이메일 입력값을 제어하는 컨트롤러

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
            _buildInputField('이메일', _emailController),
            SizedBox(height: 40),
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
                child: Text('비밀번호 찾기',style: TextStyle(fontSize: 16, color: Colors.white)),
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
    print("이메일 : $email");
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이메일을 입력해주세요.')),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://34.64.110.210:8080/email/request-temp-password'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"email": email}), // 사용자가 입력한 이메일을 JSON body에 포함
    );
    print("비밀번호 찾기 : ${response.body},$email");
    if (response.statusCode == 200) {
      // 서버로부터 반환된 JSON 데이터에서 비밀번호를 추출
      final Map<String, dynamic> responseData = json.decode(response.body);
      final newPassword = responseData['newPassword']; // 서버에서 반환된 비밀번호

      // 모달 창에 새 비밀번호를 표시하고 확인을 누르면 로그인 화면으로 이동
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
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
