import 'package:flutter/material.dart';

class NicknameScreen extends StatelessWidget {
  final TextEditingController _nicknameController = TextEditingController();

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
              '닉네임은 한글로 최대 6자까지 입력 가능하며, 주문하실 메뉴를 찾으실 때 등록된 닉네임을 불러 드립니다.',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: '닉네임 입력',
                border: OutlineInputBorder(),
              ),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // 여기에 닉네임을 저장하는 로직을 추가
                  if (_nicknameController.text.isNotEmpty) {
                    Navigator.pop(context); // 저장 후 이전 화면으로 이동
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, // 버튼 색상
                  padding: EdgeInsets.symmetric(vertical: 16),
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
