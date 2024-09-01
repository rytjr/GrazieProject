import 'package:flutter/material.dart';

class AdmobTextScreen extends StatelessWidget {
  final String adInfoPolicy = """
Grazie 광고성 정보 수집 및 이용 동의

1. 광고성 정보 수집 및 이용 목적
Grazie는 회원님께 맞춤형 광고 및 프로모션 정보를 제공하기 위해 광고성 정보를 수집하고 이용합니다. 이를 통해 회원님께 더욱 유익한 혜택을 제공할 수 있습니다.

2. 수집하는 정보의 항목
광고성 정보 제공을 위해 수집하는 정보: 쿠키, 접속 로그, IP 주소, 이용 기록 등

3. 정보 제공 및 보유 기간
회원님의 광고성 정보는 동의일로부터 서비스 탈퇴 시까지 보유하며, 이후 해당 정보를 지체 없이 파기합니다.

4. 정보의 제3자 제공
회사는 회원님의 광고성 정보를 외부 제휴사와 공유할 수 있으며, 이 경우 회원님의 동의를 받습니다.

5. 동의 철회
회원님은 언제든지 광고성 정보 수신 동의를 철회할 수 있으며, 이에 따라 수집된 정보의 처리도 중단됩니다.

"""; // 광고성 정보 수집 및 이용 동의 내용

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("광고성 정보 수집 및 이용 동의"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "광고성 정보 수집 및 이용 동의",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  adInfoPolicy,
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
