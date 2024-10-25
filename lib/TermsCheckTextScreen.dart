import 'package:flutter/material.dart';

class TermsCheckTextScreen extends StatelessWidget {
  final String termsOfService = """
Grazie 이용 약관

1. 서비스 소개
Grazie(이하 "서비스")는 고객님께 고품질의 커피와 베이커리 제품을 제공하는 온라인 플랫폼입니다. 본 서비스는 Grazie(이하 "회사")가 운영합니다.

2. 개인정보 수집 및 이용
회사는 고객님의 개인정보를 안전하게 관리하며, 제공된 정보는 서비스 제공 및 개선을 위해 사용됩니다.

3. 결제 및 환불
모든 결제는 안전하게 처리되며, 환불 정책은 해당 상품의 조건에 따라 달라질 수 있습니다.

4. 책임의 한계
회사는 고객이 서비스 이용 중 발생하는 손해에 대해 제한된 책임을 집니다.

5. 계정 관리
고객은 본 서비스의 계정을 안전하게 관리해야 하며, 계정 도용 등으로 발생하는 문제에 대해 회사는 책임지지 않습니다.

"""; // 약관 내용

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("이용 약관"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "이용 약관",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  termsOfService,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () {
            //     // 동의 버튼이 눌렸을 때의 동작
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Color(0xFF5B1333), // primary 대신 backgroundColor 사용
            //     minimumSize: Size(double.infinity, 50),
            //   ),
            //   child: Text(
            //     "동의",
            //     style: TextStyle(color: Colors.white, fontSize: 18),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
