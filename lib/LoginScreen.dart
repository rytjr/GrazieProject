import 'package:flutter/material.dart';
import 'package:fluttertest/IdFindScreen.dart';
import 'package:fluttertest/PasswordChangeScreen.dart';
import 'package:fluttertest/PasswordFindScreen.dart';
import 'package:fluttertest/TermsOfUseScreen.dart';
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
  bool _obscureText = true; // 비밀번호 가시성 토글 상태

  Future<void> _login() async {
    final String id = _idController.text;
    final String password = _passwordController.text;

    // 입력값이 없을 때 경고 메시지 표시
    if (id.isEmpty || password.isEmpty) {
      _showErrorModal('아이디와 비밀번호를 입력해 주세요.');
      return;
    }

    // API로 로그인 요청
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/auth/login'), // localhost 대신 에뮬레이터용 IP 사용
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userid': id, 'password': password}), // 서버에서 기대하는 키 이름 확인
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.isEmpty) {
        // 로그인 실패 - 빈 배열이면 모달창을 띄움
        _showErrorModal('아이디 혹은 비밀번호를 잘못 입력하셨습니다.');
      } else {
        // 로그인 성공 - 토큰 저장 후 HomeScreen으로 이동
        await _saveTokens(responseData['accessToken'], responseData['refreshToken']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      }
    } else {
      // 로그인 실패 시 모달창 띄우기
      _showErrorModal('로그인에 실패했습니다. 다시 시도해 주세요.');
    }
  }

  // SecureStorage에 토큰 저장
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  // 로그인 실패 시 모달창 띄우기
  void _showErrorModal(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그인 오류'),
          content: Text(message),
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                obscureText: _obscureText, // 비밀번호 가시성 설정
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => IdFindScreen()),
                      );
                    },
                    child: Text('아이디 찾기'),
                  ),
                  Text('|'),
                  TextButton(
                    onPressed: () {
                      // 비밀번호 찾기 동작
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PasswordFindScreen()),
                      );
                    },
                    child: Text('비밀번호 찾기'),
                  ),
                  Text('|'),
                  TextButton(
                    onPressed: () {
                      // 비밀번호 변경 동작
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PasswordChangeScreen()),
                      );
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => TermsOfUseScreen()),
                        );
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
