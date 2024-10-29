import 'package:flutter/material.dart';
import 'package:fluttertest/HomeScrean.dart';
import 'package:fluttertest/SecureStorageService.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserInfoChangeScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<UserInfoChangeScreen> {
  Map<String, dynamic> userProfile = {}; // 사용자 정보 저장
  bool isGenderValid = true; // 성별 유효성 확인용 변수
  final TextEditingController genderController = TextEditingController(); // 성별 입력 컨트롤러

  @override
  void initState() {
    super.initState();
    fetchUserProfile(); // 사용자 정보 가져오기
  }

  // 사용자 정보 가져오기
  Future<void> fetchUserProfile() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    final response = await http.get(
      Uri.parse('http://34.64.110.210:8080/api/user-info'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final decodedResponseBody = utf8.decode(response.bodyBytes);
    print("정보 조회 결과 ${response.body}");
    print('내정보 : $decodedResponseBody');
    if (response.statusCode == 200) {
      setState(() {
        userProfile = jsonDecode(decodedResponseBody);
        // 성별을 '남' 또는 '여'로 변환
        userProfile['gender'] = userProfile['gender'] == "MALE" ? "남" : "여";
        genderController.text = userProfile['gender'] ?? '';
      });
    } else {
      throw Exception('Failed to load profile');
    }
  }

  // 성별 유효성 검사
  bool validateGender() {
    return genderController.text == "남" || genderController.text == "여";
  }

  // 사용자 정보 수정 요청 보내기
  Future<void> updateUserProfile() async {
    if (!validateGender()) {
      setState(() {
        isGenderValid = false; // 유효하지 않으면 오류 메시지 표시
      });
      return;
    }

    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    try {
      final response = await http.put(
        Uri.parse('http://34.64.110.210:8080/users/additional-info/update'), // PATCH 메서드 사용
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "gender": genderController.text == "남" ? "MALE" : "FEMALE",
          "nickname": userProfile['nickname'],
        }),
      );
      final responseBody = utf8.decode(response.bodyBytes); // UTF-8로 디코딩
      print("응답 코드: ${responseBody}");
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정이 완료되었습니다.')),
        );
        fetchUserProfile(); // 수정 후 새로고침
        setState(() {
          isGenderValid = true; // 수정이 완료되면 오류 메시지 제거
        });
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수정 중 오류가 발생했습니다: $e')),
      );
    }
  }

  // 회원탈퇴 요청 보내기
  Future<void> deleteUserAccount() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    try {
      final response = await http.delete(
        Uri.parse('http://34.64.110.210:8080/users/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('탈퇴 ${response.body}');
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원탈퇴가 완료되었습니다.')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to delete account');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원탈퇴 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, // 키보드 올라와도 버튼 고정
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('회원정보 수정'),
        centerTitle: true, // 타이틀 중앙 정렬
      ),
      body: Stack(
        children: [
          userProfile.isEmpty
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text('이름'),
                Text(userProfile['name'] ?? ''),
                Divider(),
                Text('전화번호'),
                Text(userProfile['phone'] ?? ''),
                Divider(),
                Text('닉네임'),
                Text(userProfile['nickname'] ?? ''),
                Divider(),
                Text('휴대폰'),
                Text(userProfile['phone'] ?? ''),
                Divider(),
                SizedBox(height: 20),
                Text('추가정보', style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  onChanged: (value) => userProfile['email'] = value,
                  decoration: InputDecoration(labelText: '이메일'),
                  controller: TextEditingController(text: userProfile['email']),
                ),
                TextField(
                  controller: genderController,
                  decoration: InputDecoration(
                    labelText: '성별',
                    hintText: '남 또는 여만 입력 가능합니다.',
                    errorText: isGenderValid ? null : '성별은 남 또는 여만 가능합니다.',
                  ),
                ),
                SizedBox(height: 310), // 버튼과 겹치지 않도록 추가 간격 확보
              ],
            ),
          ),

          // 로그아웃 버튼 (하단 고정 수정완료 버튼 위 15px)
          Positioned(
            bottom: 70, // 화면 하단에서 70px 위로 고정 (수정완료 버튼보다 15px 위)
            left: 16,
            right: 16,
            child: Center(
              child: TextButton(
                onPressed: () {
                  deleteUserAccount(); // 회원탈퇴 요청
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomeScreen()), // 회원정보 수정 화면으로 이동
                  );
                },
                child: Text(
                  '회원탈퇴',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),

          // 수정완료 버튼 (하단 고정)
          Positioned(
            bottom: 15, // 화면 하단에서 15px 위로 고정
            left: 16,
            right: 16,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  updateUserProfile(); // 버튼 클릭 시 유효성 검사 후 업데이트 실행
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5B1333),
                ),
                child: Text(
                  '수정완료',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UserInfoChangeScreen(),
  ));
}
