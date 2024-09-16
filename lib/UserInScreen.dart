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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // 뒤로가기 아이콘으로 변경
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 동작
          },
        ),
        centerTitle: true,
      ),
      body: Padding(
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
                validator: (value) {
                  if (value == null || value.length < 10 || value.length > 20) {
                    return '비밀번호는 10~20자리여야 합니다.';
                  }
                  if (!RegExp(r'^(?=.*?[!@#\$&*~]).{10,}$').hasMatch(value)) {
                    return '비밀번호에는 최소 한 개의 특수 문자가 포함되어야 합니다.';
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
                  if (value != _passwordController.text) {
                    return '비밀번호가 일치하지 않습니다.';
                  }
                  return null;
                },
              ),
              Spacer(),
              ElevatedButton(
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
                  backgroundColor: Colors.green, // 버튼 활성화 색상
                  minimumSize: Size(double.infinity, 50), // 버튼 크기 설정
                ),
                child: Text(
                  '다음',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
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
