import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("결제하기"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderDetails(),
              SizedBox(height: 20),
              _buildCouponSection(),
              SizedBox(height: 20),
              _buildPaymentMethod(),
              SizedBox(height: 20),
              _buildReceiptOption(),
              SizedBox(height: 20),
              _buildTotalAmount(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5B1333), // 버튼 색상
                  minimumSize: Size(double.infinity, 50), // 버튼 크기
                ),
                child: Text('5600원 결제하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderDetails() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.network(
          'https://via.placeholder.com/50', // 이미지 URL
          width: 50,
          height: 50,
        ),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '아이스 플랫 화이트',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('ICED/일회용컵'),
            Text('5600원', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Spacer(),
        Text('5600원', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCouponSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Cupon 사용", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("쿠폰"),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("결제 수단", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        ListTile(
          leading: Radio(
            value: true,
            groupValue: true,
            onChanged: (value) {},
          ),
          title: Text("신용카드 간편결제"),
        ),
      ],
    );
  }

  Widget _buildReceiptOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("현금영수증", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text("현금영수증을 신청하세요."),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalAmount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("주문 금액", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("주문 금액"),
            Text("5600원", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("최종 결제 금액", style: TextStyle(fontWeight: FontWeight.bold)),
            Text("5600원", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
