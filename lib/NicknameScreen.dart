import 'package:flutter/material.dart';
import 'package:fluttertest/SecureStorageService.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON 파싱을 위해 추가

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

  // 닉네임 수정 요청 함수
  Future<void> _updateNickname() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    final String nickname = _nicknameController.text;

    try {
      final response = await http.post(
        Uri.parse('http://34.64.110.210:8080/admin/read'), // 수정할 API 주소
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',

        },
        body: jsonEncode({'nickname': nickname}),
      );

      if (response.statusCode == 200) {
        // 닉네임 수정 성공 시 이전 화면으로 이동
        Navigator.pop(context);
      } else {
        // 실패 시 에러 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('닉네임 수정에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다. 인터넷 연결을 확인해주세요.')),
      );
      print('오류 발생: $e');
    }
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
                    ? () async {
                  await _updateNickname(); // 닉네임 수정 요청
                }
                    : null, // 입력이 완료되지 않으면 버튼 비활성화
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown, // 버튼 색상
                  padding: EdgeInsets.symmetric(vertical: 16),
                  disabledBackgroundColor: Colors.grey[300], // 비활성화 시 색상
                ),
                child: Text(
                  '확인',
                  style: TextStyle(fontSize: 16,color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
