import 'package:flutter/material.dart';
import 'package:fluttertest/AdmobTextScreen.dart';
import 'package:fluttertest/UserCheckTextScreen.dart';
import 'package:fluttertest/TermsCheckTextScreen.dart';
import 'package:fluttertest/UserInScreen.dart';

class TermsOfUseScreen extends StatefulWidget {
  @override
  _TermsOfUseScreenState createState() => _TermsOfUseScreenState();
}

class _TermsOfUseScreenState extends State<TermsOfUseScreen> {
  bool isAllSelected = false;
  Map<String, bool> terms = {
    "이용약관 동의": false,
    "개인정보 수집 및 이용동의": false,
    "스타벅스 카드 이용약관": false,
    "광고성 정보 수신동의": false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("약관 동의"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // 뒤로가기 아이콘으로 변경
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 동작
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "고객님 환영합니다!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildAllAgreeCheckbox(),
            Divider(),
            _buildTermCheckbox("이용약관 동의"),
            _buildTermCheckbox("개인정보 수집 및 이용동의"),
            _buildTermCheckbox("광고성 정보 수신동의"),
            SizedBox(height: 20),
            Spacer(),
            ElevatedButton(
              onPressed: _areRequiredTermsSelected() ? _onNextPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _areRequiredTermsSelected() ? Colors.brown : Colors.grey,
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                "다음",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllAgreeCheckbox() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 7.0), // 좌측에 7의 패딩 추가
          child: Checkbox(
            value: isAllSelected,
            onChanged: (bool? value) {
              setState(() {
                isAllSelected = value ?? false;
                terms.updateAll((key, value) => isAllSelected);
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 7.0), // 좌측에 7의 패딩 추가
          child: Text("약관 전체동의", style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildTermCheckbox(String term) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 7.0), // 좌측에 7의 패딩 추가
          child: Checkbox(
            value: terms[term],
            onChanged: (bool? value) {
              setState(() {
                terms[term] = value ?? false;
                isAllSelected = !terms.containsValue(false);
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 7.0), // 좌측에 7의 패딩 추가
          child: Text(term, style: TextStyle(fontSize: 16)),
        ),
        Spacer(),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios),
          onPressed: () {
            if (term == "이용약관 동의") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TermsCheckTextScreen()),
              );
            } else if (term == "개인정보 수집 및 이용동의") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserCheckTextScreen()),
              );
            } else if (term == "광고성 정보 수신동의") {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdmobTextScreen()),
              );
            }
          },
        ),
      ],
    );
  }

  bool _areRequiredTermsSelected() {
    return terms["이용약관 동의"] == true &&
        terms["개인정보 수집 및 이용동의"] == true;
  }

  void _onNextPressed() {
    // 다음 버튼 눌렸을 때의 동작
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserInScreen()),
    );
  }
}
