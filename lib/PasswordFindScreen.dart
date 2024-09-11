import 'package:flutter/material.dart';

class PasswordFindScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // 비밀번호 찾기 텍스트 제거 및 전체 디자인을 위로 올리기 위해 SizedBox의 height 값을 줄였습니다.
            SizedBox(height: 20),
            // 아이디 입력 필드
            _buildInputField('아이디'),
            SizedBox(height: 20),
            // 이름 입력 필드
            _buildInputField('이름'),
            SizedBox(height: 20),
            // 이메일 입력 필드
            _buildInputField('이메일'),
            SizedBox(height: 40),
            // 비밀번호 찾기 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // 비밀번호 찾기 버튼 눌렀을 때 동작
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00C853), // 버튼 색상 (녹색)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('비밀번호 찾기'),
              ),
            ),
            SizedBox(height: 20),
            // 하단 로그인, 아이디 찾기, 회원가입 텍스트
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      // 로그인으로 이동
                    },
                    child: Text('로그인'),
                  ),
                  Text('/'),
                  TextButton(
                    onPressed: () {
                      // 아이디 찾기 화면으로 이동
                    },
                    child: Text('아이디 찾기'),
                  ),
                  Text('/'),
                  TextButton(
                    onPressed: () {
                      // 회원가입 화면으로 이동
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

  // 텍스트 입력 필드 디자인을 위한 메서드
  Widget _buildInputField(String labelText) {
    return TextField(
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
}

void main() => runApp(MaterialApp(
  home: PasswordFindScreen(),
));
