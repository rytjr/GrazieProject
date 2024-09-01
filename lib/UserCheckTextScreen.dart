import 'package:flutter/material.dart';

class UserCheckTextScreen extends StatelessWidget {
  final String privacyPolicy = """
Grazie 개인정보 수집 및 이용 동의

1. 개인정보의 수집 및 이용 목적
Grazie는 회원님의 개인정보를 안전하게 관리하며, 수집된 정보는 서비스 제공, 고객 관리, 마케팅 및 광고, 법적 의무 이행 등을 위해 사용됩니다.

2. 수집하는 개인정보의 항목
회원 가입 시 필수적으로 수집되는 정보: 이름, 이메일, 휴대전화번호, 주소 등
서비스 이용 과정에서 자동으로 생성되는 정보: IP 주소, 쿠키, 방문 기록 등

3. 개인정보의 보유 및 이용 기간
회원 탈퇴 시까지 또는 법적 의무 보유 기간 동안 개인정보를 보유합니다. 이후에는 해당 정보를 지체 없이 파기합니다.

4. 개인정보의 제3자 제공
회사는 원칙적으로 회원님의 개인정보를 외부에 제공하지 않습니다. 다만, 법령에 따라 요구되는 경우에 한해 제3자에게 제공될 수 있습니다.

5. 개인정보의 안전성 확보 조치
회사는 회원님의 개인정보를 안전하게 보호하기 위해 최선의 보안 조치를 취하고 있습니다.

6. 개인정보 처리방침의 변경
회사는 개인정보 처리방침을 변경할 수 있으며, 변경된 내용은 웹사이트를 통해 공지됩니다.

"""; // 개인정보 수집 및 이용 동의 내용

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("개인정보 수집 및 이용 동의"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "개인정보 수집 및 이용 동의",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  privacyPolicy,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 동의 버튼이 눌렸을 때의 동작
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // primary 대신 backgroundColor 사용
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                "동의",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
