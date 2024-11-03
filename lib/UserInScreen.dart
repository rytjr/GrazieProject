import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertest/LoginScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'dart:io';


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
  final TextEditingController _confirmPasswordController = TextEditingController();
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

      try {
        final response = await http.post(
          Uri.parse('http://34.64.110.210:8080/users/join'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestData),
        );
        print("회가 : ${response.body}");
        print(response.request);
        if (response.statusCode == 201) {
          final userId = int.tryParse(response.body);
          if (userId != null) {
            // 회원가입 성공 시 추가 정보 요청
            print('성공 $userId');
            await _sendAdditionalInfo(userId);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('네트워크 오류가 발생했습니다.')),
        );
      }
    }
  }

  Future<void> _sendAdditionalInfo(int userId) async {
    final uri = Uri.parse(
        'http://34.64.110.210:8080/users/additional-info/$userId/additionalInfoJoin');
    final request = http.MultipartRequest('POST', uri);

    // 기본 이미지를 전송하도록 설정
    final byteData = await rootBundle.load('android/assets/images/event4.png');
    final file = File('${(await getTemporaryDirectory()).path}/default_profile_image.jpg');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    request.files.add(await http.MultipartFile.fromPath(
      'profileImage',
      file.path,
    ));

    // additionalInfo 필드 추가
    final additionalInfo = {
      "nickname": "heeSu",
      "gender": "MALE"
    };
    request.fields['additionalInfo'] = jsonEncode(additionalInfo);

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("추가 정보 : $responseBody");
      print('request : ${response.request}');

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('추가 정보 전송 실패. 응답: $responseBody')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('네트워크 오류가 발생했습니다.')),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  style: TextStyle(fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5B1333)),
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
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(labelText: '전화번호'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '전화번호를 입력해 주세요.';
                    } else if (value.length != 11) {
                      return '올바른 전화번호를 입력해 주세요.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _idController,
                  decoration: InputDecoration(labelText: '아이디 (4~13자리 이내)'),
                  validator: (value) {
                    if (value == null || value.length < 4 ||
                        value.length > 13) {
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
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호 확인',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 다시 입력해 주세요.';
                    }
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다.';
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
                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled ? () => _signUp() : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5B1333),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      disabledBackgroundColor: Colors.grey[300],
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
