import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertest/HomeScrean.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _storage = FlutterSecureStorage();

  Future<void> _login() async {
    final String id = _idController.text;
    final String password = _passwordController.text;

    // API로 로그인 요청
    final response = await http.post(
      Uri.parse('http://localhost:8080/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'password': password}),
    );

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (responseData.isEmpty) {
      // 로그인 실패 - 빈 배열이면 모달창을 띄움
      _showErrorModal();
    } else {
      // 로그인 성공 - 토큰 저장 후 HomeScreen으로 이동
      await _saveTokens(responseData['accessToken'], responseData['refreshToken']);
      print("Access Token: ${responseData['accessToken']}");
      print("Refresh Token: ${responseData['refreshToken']}");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(), // 로그인 상태를 true로 넘김
        ),
      );
    }
  }

  // SecureStorage에 토큰 저장
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  // 로그인 실패 시 모달창 띄우기
  void _showErrorModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그인 오류'),
          content: Text('아이디 혹은 비밀번호를 잘못 입력하셨습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'A GRAZIE',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 40),
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: '아이디 입력',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: '비밀번호 입력',
                  suffixIcon: Icon(Icons.visibility_off),
                ),
                obscureText: true,
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _login, // 로그인 버튼 눌렀을 때 API 요청
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: Text('로그인'),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      // 아이디 찾기 동작
                    },
                    child: Text('아이디 찾기'),
                  ),
                  Text('|'),
                  TextButton(
                    onPressed: () {
                      // 비밀번호 찾기 동작
                    },
                    child: Text('비밀번호 찾기'),
                  ),
                  Text('|'),
                  TextButton(
                    onPressed: () {
                      // 비밀번호 변경 동작
                    },
                    child: Text('비밀번호 변경'),
                  ),
                ],
              ),
              SizedBox(height: 40), // Spacer 대신 여유 공간 추가
              Center(
                child: Column(
                  children: [
                    Text(
                      'Grazie 앱이 처음이신가요?',
                      style: TextStyle(
                        color: Colors.redAccent,
                      ),
                    ),
                    SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () {
                        // 회원가입 화면으로 이동
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.black),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text(
                        '회원가입하기',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
