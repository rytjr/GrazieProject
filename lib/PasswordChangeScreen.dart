import 'package:flutter/material.dart';
import 'package:fluttertest/HomeScrean.dart';
import 'package:fluttertest/SecureStorageService.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordChangeScreen extends StatefulWidget {
  @override
  _PasswordChangeScreenState createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  TextEditingController _currentPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  String _errorMessage = '';

  // 비밀번호가 같은지 실시간 확인하는 함수
  void _checkPasswordMatch() {
    setState(() {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        _errorMessage = '비밀번호가 일치하지 않습니다';
      } else {
        _errorMessage = '';
      }
    });
  }

  // 비밀번호 변경 요청 함수
  Future<void> _changePassword() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    print('토큰토큼 ${token}');
    final String currentPassword = _currentPasswordController.text;
    final String newPassword = _newPasswordController.text;
    final response = await http.put(
      Uri.parse('http://34.64.110.210:8080/users/changePassword'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "currentPassword": currentPassword,
        'newPassword': newPassword,
      }),
    );
    print('비밀번호 ${response.body}');
    if (response.statusCode == 200) {
      // 비밀번호 변경 성공 모달 띄우기
      _showResultModal('비밀번호가 변경되었습니다.', true);
      await storageService.deleteToken();
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen()), // 회원정보 수정 화면으로 이동
      );
    } else {
      // 비밀번호 변경 실패 모달 띄우기
      _showResultModal('현재 비밀번호를 확인해 주세요.', false);
    }
  }

  // 결과 모달 창 표시
  void _showResultModal(String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('알림'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isSuccess) {
                  Navigator.pop(context); // 성공 시 화면을 닫음
                }
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
      resizeToAvoidBottomInset: false, // 키보드 올라와도 버튼 고정
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('비밀번호 변경'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 스크롤 가능한 비밀번호 입력 필드들
          Padding(
            padding: const EdgeInsets.only(bottom: 80), // 버튼과 겹치지 않도록 여유 공간 확보
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _currentPasswordController,
                    decoration: InputDecoration(
                      labelText: '현재 비밀번호',
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: '새 비밀번호',
                    ),
                    obscureText: true,
                    onChanged: (value) => _checkPasswordMatch(),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: '새 비밀번호 확인',
                    ),
                    obscureText: true,
                    onChanged: (value) => _checkPasswordMatch(),
                  ),
                  SizedBox(height: 450),
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),

          // 화면 하단에서 20px 위로 고정된 버튼
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20, // 화면 맨 하단에서 20px 위로 고정
            left: 16,
            right: 16,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_newPasswordController.text ==
                      _confirmPasswordController.text) {
                    _changePassword();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5B1333),
                ),
                child: Text(
                  '확인',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}