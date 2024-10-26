import 'package:flutter/material.dart';
import 'package:fluttertest/SecureStorageService.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CouponScreen extends StatefulWidget {
  @override
  _CouponScreenState createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  List<dynamic> coupons = [];
  bool isLoading = true;
  String? selectedCouponId; // 선택된 쿠폰 ID 저장

  @override
  void initState() {
    super.initState();
    fetchCoupons(); // 쿠폰 데이터를 서버에서 받아오는 함수 호출
  }

  // 서버에서 쿠폰 데이터를 받아오는 함수
  void fetchCoupons() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    // 서버의 URL을 정확하게 입력합니다.
    final response = await http.get(Uri.parse('http://34.64.110.210:8080/api/coupons/list'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    final decodedResponseBody = utf8.decode(response.bodyBytes);
    print('쿠폰 $decodedResponseBody');
    if (response.statusCode == 200) {
      setState(() {
        coupons = jsonDecode(decodedResponseBody);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load coupons');
    }
  }

  // 쿠폰 발급 모달창 띄우기
  void _showCouponModal(String couponName, String couponId) {
    showDialog(

      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('쿠폰 발급'),
          content: Text('$couponName 쿠폰을 발급하시겠습니까?'),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop(); // 모달창 닫기
              },
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () async {
                // 쿠폰 발급 통신 요청
                SecureStorageService storageService = SecureStorageService();
                String? token = await storageService.getToken();

                final response = await http.post(
                  Uri.parse('http://34.64.110.210:8080/api/coupons/issue'),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token'
                  },
                  body: jsonEncode({'couponId': couponId}),
                );

                if (response.statusCode == 200) {
                  // 발급 성공 시 처리
                  setState(() {
                    selectedCouponId = couponId; // 선택된 쿠폰 ID 저장
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$couponName 쿠폰이 발급되었습니다.')),
                  );
                } else {
                  // 발급 실패 시 처리
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('쿠폰 발급에 실패했습니다.')),
                  );
                }

                Navigator.of(context).pop(); // 모달창 닫기
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
          return CouponCard(
            coupon: coupons[index],
            isSelected: selectedCouponId == coupons[index]['id'].toString(),
            onSelected: (String couponId, String couponName) {
              _showCouponModal(couponName, couponId); // 쿠폰 클릭 시 모달창 띄우기
            },
          );
        },
      ),
    );
  }
}

// 쿠폰 카드 UI
class CouponCard extends StatelessWidget {
  final dynamic coupon;
  final bool isSelected;
  final Function(String, String) onSelected; // 쿠폰 ID와 이름 전달

  const CouponCard({
    required this.coupon,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 쿠폰 선택 시 ID와 이름을 전달하여 모달창에서 확인
        onSelected(coupon['id'].toString(), coupon['couponName']);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.shade300), // 선택된 쿠폰 강조
        ),
        color: isSelected ? Colors.blue.shade50 : Colors.white, // 선택되면 배경색 변경
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${coupon['couponName']} 쿠폰', // 서버의 couponName 사용
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '${coupon['description']}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                '기간 ${coupon['expirationDate']}', // 서버의 expirationDate 사용
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              SizedBox(height: 16),
            ],
          ),
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
