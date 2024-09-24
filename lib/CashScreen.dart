import 'package:flutter/material.dart';

class CashScreen extends StatefulWidget {
  @override
  _CashReceiptScreenState createState() => _CashReceiptScreenState();
}

class _CashReceiptScreenState extends State<CashScreen> {
  String _receiptType = "personal"; // 기본 선택 타입: 개인소득 공제
  bool _isSaveReceiptInfo = false; // 현금 영수증 발급 정보를 저장하는지 여부
  TextEditingController _phoneController = TextEditingController(); // 전화번호 입력 필드 컨트롤러

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('현금 영수증'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0), // 전체적인 패딩
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '현금 영수증',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildRadioOption("개인소득 공제", "personal"),
                SizedBox(width: 30), // 라디오 버튼 간의 간격
                _buildRadioOption("사업자증빙용", "business"),
              ],
            ),
            SizedBox(height: 30),
            _buildPhoneNumberInput(),
            SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _isSaveReceiptInfo,
                  onChanged: (bool? value) {
                    setState(() {
                      _isSaveReceiptInfo = value ?? false;
                    });
                  },
                ),
                Text(
                  '입력한 현금 영수증 발급정보를 저장합니다.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            Spacer(),
            _buildApplyButton(),
          ],
        ),
      ),
    );
  }

  // 라디오 버튼 위젯
  Widget _buildRadioOption(String title, String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _receiptType,
          onChanged: (String? newValue) {
            setState(() {
              _receiptType = newValue!;
            });
          },
        ),
        Text(title, style: TextStyle(fontSize: 16)),
      ],
    );
  }

  // 전화번호 입력 필드 위젯
  Widget _buildPhoneNumberInput() {
    return TextField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: '휴대 전화 번호',
        border: OutlineInputBorder(), // 테두리 스타일
      ),
    );
  }

  // 신청하기 버튼
  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // 신청하기 버튼 클릭 시 동작
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF880E4F), // 와인색 버튼
        ),
        child: Text('신청하기', style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: CashScreen(),
));
