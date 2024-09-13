import 'package:flutter/material.dart';
import 'package:fluttertest/CouponScreen.dart';

import 'package:fluttertest/NicknameScreen.dart';
import 'package:fluttertest/UserInfoChangeScreen.dart';

class MyPageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('마이페이지'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 기능
          },
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '구교석 님',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30),
            ListTile(
              title: Text('닉네임'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NicknameScreen()), // 닉네임 화면으로 이동
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text('회원정보 수정'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserInfoChangeScreen()), // 회원정보 수정 화면으로 이동
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text('쿠폰'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CouponScreen()), // 쿠폰 화면으로 이동
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
