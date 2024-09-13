import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CouponScreen extends StatefulWidget {
  @override
  _CouponScreenState createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  List<dynamic> coupons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCoupons(); // 쿠폰 데이터를 서버에서 받아오는 함수 호출
  }

  // 서버에서 쿠폰 데이터를 받아오는 함수
  void fetchCoupons() async {
    final response = await http.get(Uri.parse('http://localhost:8080/api/coupons'));

    if (response.statusCode == 200) {
      setState(() {
        coupons = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load coupons');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('쿠폰'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Row(
            children: [
              Expanded(
                child: TabBarItem(
                  label: '사용 가능한 쿠폰',
                  isSelected: true, // 기본으로 선택
                ),
              ),
              Expanded(
                child: TabBarItem(
                  label: '사용한 쿠폰',
                  isSelected: false,
                ),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 데이터 로딩 중
          : ListView.builder(
        itemCount: coupons.length,
        itemBuilder: (context, index) {
          return CouponCard(coupon: coupons[index]);
        },
      ),
    );
  }
}

// 쿠폰 카드 UI
class CouponCard extends StatelessWidget {
  final dynamic coupon;

  const CouponCard({required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${coupon['discount']}% 할인',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '${coupon['description']}',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            Text(
              '기간 ${coupon['expiry']}', // 기간 정보
              style: TextStyle(fontSize: 14, color: Colors.red),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.cloud_download, color: Colors.blue),
                onPressed: () {
                  // 다운로드 아이콘 클릭 시 동작 추가 가능
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 탭바 아이템 구성
class TabBarItem extends StatelessWidget {
  final String label;
  final bool isSelected;

  const TabBarItem({
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isSelected ? Colors.black : Colors.grey.shade300,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: CouponScreen(),
  ));
}
