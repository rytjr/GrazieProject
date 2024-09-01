import 'package:flutter/material.dart';

class UserEmailCheckScreen extends StatefulWidget {
  final String name;
  final String phone;
  final String id;
  final String password;

  UserEmailCheckScreen({
    required this.name,
    required this.phone,
    required this.id,
    required this.password,
  });

  @override
  _UserEmailCheckScreenState createState() => _UserEmailCheckScreenState();
}

class _UserEmailCheckScreenState extends State<UserEmailCheckScreen> {
  // 나머지 코드...

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
              decoration: InputDecoration(
                labelText: '이메일을 입력해 주세요',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 이메일 확인 처리
              },
              child: Text('이메일이 확인되었습니다.'),
            ),
            SizedBox(height: 20),
            Text(
              '이름: ${widget.name}',
              style: TextStyle(color: Colors.black),
            ),
            Text(
              '전화번호: ${widget.phone}',
              style: TextStyle(color: Colors.black),
            ),
            Text(
              '아이디: ${widget.id}',
              style: TextStyle(color: Colors.black),
            ),
            // 비밀번호는 보통 보여주지 않음
          ],
        ),
      ),
    );
  }
}
