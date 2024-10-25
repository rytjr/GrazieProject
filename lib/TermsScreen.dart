import 'package:flutter/material.dart';
import 'AdmobTextScreen.dart';
import 'TermsCheckTextScreen.dart';

class TermsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
        ],
      ),
    );
  }
}
