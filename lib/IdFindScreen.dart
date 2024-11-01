import 'dart:convert'; // JSON 파싱을 위해 추가
import 'package:flutter/material.dart';
import 'package:fluttertest/SecureStorageService.dart';
import 'package:http/http.dart' as http;

class IdFindScreen extends StatefulWidget {
  @override
  _IdFindScreenState createState() => _IdFindScreenState();
}

class _IdFindScreenState extends State<IdFindScreen> {
  final TextEditingController _emailController = TextEditingController(); // 이메일 입력 컨트롤러

  @override
  void dispose() {
    _emailController.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  Future<void> _findId() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    final email = _emailController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이메일을 입력해주세요.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://34.64.110.210:8080/email/find-id'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'email': email}),
      );
      print('아이디 ${response.body}');
      if (response.statusCode == 200) {
        // 성공적으로 요청이 완료되었을 때 모달창 띄우기
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('알림'),
              content: Text('새로운 아이디를 이메일로 발송하였습니다!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 모달창 닫기
                    Navigator.pop(context);
                  },
                  child: Text('확인'),
                ),
              ],
            );
          },
        );
      } else {
        final errorMessage = jsonDecode(response.body)?? '아이디 찾기 요청에 실패했습니다.';
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('요청 실패'),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // 모달창 닫기
                  },
                  child: Text('확인'),
                ),
              ],
            );
          },
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
      resizeToAvoidBottomInset: false, // 키보드 올라와도 버튼 고정
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('아이디 찾기'),
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
            // 이메일 입력 필드
            TextField(
              controller: _emailController, // 이메일 컨트롤러 연결
              decoration: InputDecoration(
                labelText: '이메일 입력',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 630),
            // 아이디 찾기 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _findId, // 아이디 찾기 동작
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5B1333),
                ),
                child: Text(
                  '아이디 찾기',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: IdFindScreen(),
));
