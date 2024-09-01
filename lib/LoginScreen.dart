import 'package:flutter/material.dart';
import 'package:fluttertest/IdFindScreen.dart';
import 'package:fluttertest/TermsOfUseScreen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
        centerTitle: true,
      ),
      body: Padding(
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
              decoration: InputDecoration(
                labelText: '아이디 입력',
              ),
            ),
            SizedBox(height: 20),
            TextField(
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
                onPressed: () {
                  // 로그인 버튼 눌렸을 때 동작
                },
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
                      MaterialPageRoute(
                        builder: (context) => IdFindScreen(),
                      ),
                    );
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
            Spacer(),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TermsOfUseScreen(),
                        ),
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
    );
  }
}

// 여기에 TermsOfUseScreen 클래스를 추가하여 회원가입 화면으로 연결합니다.
// import 'TermsOfUseScreen.dart' 사용하시고, 이미 있다면 생략해도 됩니다.
