import 'package:flutter/material.dart';
import 'package:fluttertest/LoginScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class UserInScreen extends StatefulWidget {
  @override
  _UserInScreenState createState() => _UserInScreenState();
}

class _UserInScreenState extends State<UserInScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isButtonEnabled = false;

  // 회원가입 요청
  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      final requestData = {
        'userId': _idController.text,
        'password': _passwordController.text,
        'email': _emailController.text,
        'name': _nameController.text,
        'phone': _phoneController.text,
      };

      print('전송할 데이터: ${jsonEncode(requestData)}');

      try {
        final response = await http.post(
          Uri.parse('http://34.64.110.210:8080/users/join'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestData),
        );

        print('응답 상태 코드: ${response.statusCode}');
        print('응답 본문: ${response.body}');

        if (response.statusCode == 201) {
          final userId = int.tryParse(response.body); // 응답 본문을 int로 변환

          if (userId != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('회원가입이 완료되었습니다.')),
            );

            await _sendAdditionalInfo(userId);
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('서버 응답 형식이 올바르지 않습니다.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('서버 오류가 발생했습니다. 응답: ${response.body}')),
          );
        }
      } catch (e) {
        print('오류 발생: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('네트워크 오류가 발생했습니다.')),
        );
      }
    }
  }

  Future<void> _sendAdditionalInfo(int userId) async {
    final uri = Uri.parse('http://34.64.110.210:8080/users/additional-info/$userId/additionalInfoJoin?additionalInfo=null');

    try {
      // MultipartRequest로 변경
      final request = http.MultipartRequest('POST', uri)
        ..headers['Content-Type'] = 'multipart/form-data';

      // 필요시 profileImage 파일을 추가하거나, 빈 데이터를 추가하여 multipart 형식 충족
      request.fields['profileImage'] = ''; // 빈 값으로 설정

      // 서버에 요청
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('추가 정보 응답 상태 코드: ${response.statusCode}');
      print('추가 정보 응답 본문: $responseBody');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('추가 정보가 성공적으로 저장되었습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('추가 정보 저장에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      print('추가 정보 전송 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('추가 정보 전송 중 네트워크 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('회원가입'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            onChanged: () {
              setState(() {
                _isButtonEnabled = _idController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty &&
                    _emailController.text.isNotEmpty &&
                    _nameController.text.isNotEmpty &&
                    _phoneController.text.isNotEmpty;
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '아이디와 비밀번호를\n입력해 주세요.',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: '이름'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '이름을 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: '전화번호'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '전화번호를 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _idController,
                  decoration: InputDecoration(labelText: '아이디 (4~13자리 이내)'),
                  validator: (value) {
                    if (value == null || value.length < 4 || value.length > 13) {
                      return '아이디는 4~13자리여야 합니다.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호 (10~20자리, 특수문자 포함)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력해 주세요.';
                    } else if (value.length < 10 || value.length > 20) {
                      return '비밀번호는 10~20자리여야 합니다.';
                    }
                    final specialCharRegExp = RegExp(r'[!@#\$&*~]');
                    if (!specialCharRegExp.hasMatch(value)) {
                      return '비밀번호에는 특수문자가 포함되어야 합니다.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: '이메일'),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return '유효한 이메일을 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled
                        ? () async {
                      await _signUp(); // 회원가입 요청
                    }
                        : null, // 입력이 완료되지 않으면 버튼 비활성화
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5B1333), // 버튼 색상
                      padding: EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: Colors.grey[300], // 비활성화 시 색상
                    ),
                    child: Text(
                      '확인',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
