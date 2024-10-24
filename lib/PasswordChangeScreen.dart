import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: Text('비밀번호 변경'),
        centerTitle: true,
      ),
      body: Padding(
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
              onChanged: (value) => _checkPasswordMatch(), // 입력할 때마다 비교
            ),
            SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: '새 비밀번호 확인',
              ),
              obscureText: true,
              onChanged: (value) => _checkPasswordMatch(), // 입력할 때마다 비교
            ),
            SizedBox(height: 10),
            // 비밀번호가 일치하지 않으면 오류 메시지 표시
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.white),
              ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // 확인 버튼 눌렀을 때의 동작 (비밀번호가 일치하면 통신 실행)
                  if (_newPasswordController.text == _confirmPasswordController.text) {
                    _changePassword();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF863C07),
                ),
                child: Text('확인',style:TextStyle(fontSize: 18,color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
