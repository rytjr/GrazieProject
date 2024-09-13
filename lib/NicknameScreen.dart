import 'package:flutter/material.dart';

class NicknameScreen extends StatefulWidget {
  @override
  _NicknameScreenState createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isButtonEnabled = false;

  // 닉네임 입력 제한 (한글, 영어, 10자 이하)
  void _validateNickname(String nickname) {
    final RegExp nicknameRegExp = RegExp(r'^[a-zA-Z가-힣]{1,10}$'); // 한글 또는 영어, 최대 10자
    setState(() {
      _isButtonEnabled = nicknameRegExp.hasMatch(nickname);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('닉네임 설정'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '사용하실 닉네임을 입력해 주세요.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '닉네임은 한글 또는 영어로 최대 10자까지 입력 가능합니다.',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: '닉네임 입력',
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              maxLength: 10,
              onChanged: _validateNickname, // 입력할 때마다 닉네임 유효성 검사
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isButtonEnabled
                    ? () {
                  if (_nicknameController.text.isNotEmpty) {
                    // 닉네임 저장 로직 추가
                    Navigator.pop(context); // 저장 후 이전 화면으로 이동
                  }
                }
                    : null, // 입력이 완료되지 않으면 버튼 비활성화
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, // 버튼 색상
                  padding: EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey[300], // 비활성화 시 색상
                ),
                child: Text(
                  '확인',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
