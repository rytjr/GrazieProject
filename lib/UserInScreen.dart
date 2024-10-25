import 'package:flutter/material.dart';
import 'package:fluttertest/UserEmailCheckScreen.dart';

class UserInScreen extends StatefulWidget {
  @override
  _UserInScreenState createState() => _UserInScreenState();
}

class _UserInScreenState extends State<UserInScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _idController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  // 비밀번호 유효성 검사 함수
  String? _validatePassword(String? value) {
    // 비밀번호가 비어 있지 않고 10~20자리 이내인지 확인
    if (value == null || value.isEmpty) {
      return '비밀번호를 입력해 주세요.';
    } else if (value.length < 10 || value.length > 20) {
      return '비밀번호는 10~20자리여야 합니다.';
    }
    // 특수문자 포함 여부 확인
    final RegExp specialCharacterRegExp = RegExp(r'[!@#\$&*~]');
    if (!specialCharacterRegExp.hasMatch(value)) {
      return '비밀번호에는 특수문자가 포함되어야 합니다.';
    }
    return null; // 문제가 없을 경우 null 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // 뒤로가기 아이콘
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 동작
          },
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(  // 스크롤 가능하게 변경
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '아이디와 비밀번호를\n입력해 주세요.',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '이름',
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: '전화번호',
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: '아이디 (4~13자리 이내)',
                  ),
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
                    labelText: '비밀번호 (10~20자리 이내, 특수문자 포함)',
                  ),
                  validator: _validatePassword, // 비밀번호 유효성 검사 함수 추가
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '비밀번호 확인',
                  ),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20), // 추가된 여백
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserEmailCheckScreen(
                              name: _nameController.text,
                              phone: _phoneController.text,
                              id: _idController.text,
                              password: _passwordController.text,
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown, // 버튼 색상
                      minimumSize: Size(double.infinity, 50), // 버튼 크기
                    ),
                    child: Text(
                      '다음',
                      style: TextStyle(color: Colors.white, fontSize: 18),
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

  Widget _buildStepCircle(int step, bool isCompleted) {
    return CircleAvatar(
      radius: 12,
      backgroundColor: isCompleted ? Colors.black : Colors.grey[300],
      child: Text(
        step.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 30,
      height: 2,
      color: Colors.grey[300],
    );
  }
}
