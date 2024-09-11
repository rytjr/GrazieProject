import 'package:flutter/material.dart';

class PasswordChangeScreen extends StatefulWidget {
  @override
  _PasswordChangeScreenState createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
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
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // 확인 버튼 눌렀을 때의 동작 (비밀번호가 일치하면 통신 준비)
                  if (_newPasswordController.text ==
                      _confirmPasswordController.text) {
                    // 비밀번호가 일치할 때만 통신 실행
                    print('비밀번호 변경 통신 실행');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                child: Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
