import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:fluttertest/SecureStorageService.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertest/LoginScreen.dart';

class UserInfoChangeScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<UserInfoChangeScreen> {
  Map<String, dynamic> userProfile = {}; // 사용자 정보 저장

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
      Uri.parse('http://34.64.110.210:8080/users/readProfile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final decodedResponseBody = utf8.decode(response.bodyBytes);
    if (response.statusCode == 200) {
      setState(() {
        userProfile = jsonDecode(decodedResponseBody);
      });
    } else {
      throw Exception('Failed to load profile');
    }
  }

  // 사용자 정보 수정 요청 보내기
  Future<void> updateUserProfile() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    try {
      final response = await http.put(
        Uri.parse('http://34.64.110.210:8080/users/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(userProfile),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정이 완료되었습니다.')),
        );
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
      appBar: AppBar(
        title: Text('회원정보 수정'),
      ),
      body: userProfile.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Divider(),
            Text('이름'),
            Text(userProfile['name'] ?? ''),
            Divider(),
            Text('아이디'),
            Text(userProfile['id'] ?? ''),
            Divider(),
            Text('생년월일'),
            Text(userProfile['birthday'] ?? ''),
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
              onChanged: (value) => userProfile['nickname'] = value,
              decoration: InputDecoration(labelText: '성별'),
              controller:
              TextEditingController(text: userProfile['nickname']),
            ),
            SizedBox(height: 20),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // 회원탈퇴 요청
                    deleteUserAccount();
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    side: BorderSide(color: Colors.red),
                  ),
                  child: Text('회원탈퇴'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // 수정 완료 요청
                    updateUserProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    padding: EdgeInsets.symmetric(
                        vertical: 15, horizontal: 30),
                  ),
                  child: Text('수정완료'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UserInfoChangeScreen(),
  ));
}



// class UserInfoChangeScreen extends StatefulWidget {
//   @override
//   _UserInfoChangeScreenState createState() => _UserInfoChangeScreenState();
// }
//
// class _UserInfoChangeScreenState extends State<UserInfoChangeScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('회원정보 수정'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '기본 정보',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 10),
//             _buildUserInfoRow('이름', '구교석'),
//             _buildUserInfoRow('아이디', '-'),
//             _buildUserInfoRow('생년월일', '2000/03/30'),
//             _buildUserInfoRow('휴대폰', '010-4541-6264'),
//             SizedBox(height: 20),
//             Text(
//               '추가정보',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 10),
//             _buildEditableInfoRow('이메일', 'kks007159@naver.com'),
//             _buildEditableInfoRow('기념일', '0330'),
//             SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () {
//                 // 수정완료 버튼 클릭 시의 동작
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.brown,
//                 minimumSize: Size(double.infinity, 50),
//               ),
//               child: Text('수정완료'),
//             ),
//             SizedBox(height: 10),
//             OutlinedButton(
//               onPressed: () {
//                 // 회원 탈퇴 버튼 클릭 시의 동작
//               },
//               style: OutlinedButton.styleFrom(
//                 side: BorderSide(color: Colors.brown),
//                 minimumSize: Size(double.infinity, 50),
//               ),
//               child: Text('회원탈퇴', style: TextStyle(color: Colors.brown)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUserInfoRow(String title, String info) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title, style: TextStyle(fontSize: 16)),
//           Text(info, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEditableInfoRow(String title, String info) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title, style: TextStyle(fontSize: 16)),
//           Expanded(
//             child: TextField(
//               decoration: InputDecoration(
//                 hintText: info,
//                 border: InputBorder.none,
//               ),
//               textAlign: TextAlign.end,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
