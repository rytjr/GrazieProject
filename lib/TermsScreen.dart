import 'package:flutter/material.dart';
import 'AdmobTextScreen.dart';
import 'TermsCheckTextScreen.dart';

class TermsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("이용약관"),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text("그라찌에 이용약관"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TermsCheckTextScreen(),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text("개인정보 수집 및 이용 동의"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdmobTextScreen(),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            title: Text("위치기반 서비스 이용약관"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 다른 화면으로 이동할 로직 추가
            },
          ),
          Divider(),
          ListTile(
            title: Text("나이스정보통신 선불카드 이용약관"),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // 다른 화면으로 이동할 로직 추가
            },
          ),
        ],
      ),
    );
  }
}
