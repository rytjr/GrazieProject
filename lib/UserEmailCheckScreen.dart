import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class UserEmailCheckScreen extends StatefulWidget {
  @override
  _UserEmailCheckScreenState createState() => _UserEmailCheckScreenState();
}

class _UserEmailCheckScreenState extends State<UserEmailCheckScreen> {
  final _emailController = TextEditingController();
  String _validationMessage = '';
  bool _isEmailValid = false;

  // 이메일 형식 검사
  bool validateEmailFormat(String email) {
    final RegExp emailRegExp = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+()",
    );
    return emailRegExp.hasMatch(email);
  }

  // 도메인 유효성 검사
  Future<bool> validateDomain(String email) async {
    final domain = email.split('@').last;
    final response = await http.get(Uri.parse('https://dns.google/resolve?name=$domain&type=MX'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // MX 레코드가 있으면 유효한 도메인으로 간주
      return data['Answer'] != null;
    } else {
      return false;
    }
  }

  // 이메일 확인 버튼 클릭 시 실행되는 메서드
  void _validateEmail() async {
    final email = _emailController.text;

    if (!validateEmailFormat(email)) {
      setState(() {
        _validationMessage = '이메일을 입력해주세요';
        _isEmailValid = false;
      });
      return;
    }

    final domainIsValid = await validateDomain(email);

    if (domainIsValid) {
      setState(() {
        _validationMessage = '확인되었습니다!';
        _isEmailValid = true;
      });
    } else {
      setState(() {
        _validationMessage = '이메일 확인하기';
        _isEmailValid = false;
      });
    }
  }

  void _navigateToNextScreen() {
    if (_isEmailValid) {
      // Navigator.push(
        // context,
        // MaterialPageRoute(builder: (context) => NextScreen()),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('이메일 확인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '이메일을 입력해 주세요',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _validateEmail,
              child: Text('이메일이 확인되었습니다.'),
            ),
            SizedBox(height: 20),
            Text(
              _validationMessage,
              style: TextStyle(
                color: _validationMessage.contains('확인')
                    ? Colors.green
                    : Colors.red,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isEmailValid ? _navigateToNextScreen : null,
              child: Text('다음'),
            ),
          ],
        ),
      ),
    );
  }
}
