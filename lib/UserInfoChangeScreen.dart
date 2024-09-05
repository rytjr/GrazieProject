import 'package:flutter/material.dart';

class UserInfoChangeScreen extends StatefulWidget {
  @override
  _UserInfoChangeScreenState createState() => _UserInfoChangeScreenState();
}

class _UserInfoChangeScreenState extends State<UserInfoChangeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원정보 수정'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '기본 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            _buildUserInfoRow('이름', '구교석'),
            _buildUserInfoRow('아이디', '-'),
            _buildUserInfoRow('생년월일', '2000/03/30'),
            _buildUserInfoRow('휴대폰', '010-4541-6264'),
            SizedBox(height: 20),
            Text(
              '추가정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            _buildEditableInfoRow('이메일', 'kks007159@naver.com'),
            _buildEditableInfoRow('기념일', '0330'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // 수정완료 버튼 클릭 시의 동작
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('수정완료'),
            ),
            SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                // 회원 탈퇴 버튼 클릭 시의 동작
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.brown),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('회원탈퇴', style: TextStyle(color: Colors.brown)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(String title, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16)),
          Text(info, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEditableInfoRow(String title, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16)),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: info,
                border: InputBorder.none,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
