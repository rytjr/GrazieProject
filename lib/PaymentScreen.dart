import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<dynamic> orders = [];
  bool _isExpanded = false; // 리스트 펼침 상태
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrderData(); // API로부터 주문 데이터를 받아옴
  }

  // API로부터 주문 데이터를 받아오는 함수
  Future<void> fetchOrderData() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/cart/items?userId=2'));

    if (response.statusCode == 200) {
      setState(() {
        orders = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load orders');
    }
  }

  // 총 가격 계산
  int calculateTotalPrice() {
    return orders.fold(0, (sum, item) => sum + (item['price'] as int) * (item['quantity'] as int));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('결제하기'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중일 때
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '주문 내역',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Divider(thickness: 2, color: Colors.grey[300]), // 굵은 회색선
            _buildOrderSummary(), // 주문 요약 (첫 아이템 + 더보기)
            Divider(thickness: 1, color: Colors.grey[300]), // 얇은 회색선
            if (_isExpanded) // 더보기 상태일 때만 전체 리스트 보여줌
              Expanded(
                child: ListView.separated(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderItem(orders[index]);
                  },
                  separatorBuilder: (context, index) => Divider(thickness: 1, color: Colors.grey[300]), // 리스트 간 경계선
                ),
              ),
            Divider(thickness: 1, color: Colors.grey[300]), // 얇은 회색선
            _buildCouponSection(), // 쿠폰 섹션
            Divider(thickness: 1, color: Colors.grey[300]), // 얇은 회색선
            _buildPaymentMethods(), // 결제 수단 섹션
            Divider(thickness: 1, color: Colors.grey[300]), // 얇은 회색선
            _buildReceiptSection(), // 현금영수증 섹션
            SizedBox(height: 20),
            _buildTotalPriceRow(), // 총 가격
            SizedBox(height: 10),
            _buildPaymentButton(), // 결제 버튼
          ],
        ),
      ),
    );
  }

  // 주문 내역 요약 위젯
  Widget _buildOrderSummary() {
    var firstItem = orders.isNotEmpty ? orders[0] : null;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded; // 더보기/줄이기 상태 토글
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (firstItem != null)
            Row(
              children: [
                Image.network(
                  firstItem['image'] ?? '',
                  width: 50,
                  height: 50,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error), // 이미지 없을 때 에러 아이콘 표시
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(firstItem['name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${firstItem['price']}원', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    Text('${firstItem['size']} / ${firstItem['cup']}', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          Text(
            _isExpanded ? '줄이기' : '더보기',
            style: TextStyle(fontSize: 16, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  // 각 주문 항목을 표시하는 위젯
  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.network(
          item['image'] ?? '',
          width: 50,
          height: 50,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.error), // 이미지 없을 때 에러 아이콘 표시
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['name'] ?? '상품 이름 없음', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('${item['size']} / ${item['cup']}', style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text('수량: ${item['quantity']}', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${item['price']}원', style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text('${(item['price'] as int) * (item['quantity'] as int)}원', style: TextStyle(fontSize: 16, color: Colors.black)),
          ],
        ),
      ],
    );
  }

  // 쿠폰 섹션
  Widget _buildCouponSection() {
    return ListTile(
      title: Text(
        'Coupon 사용',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        // 쿠폰 사용 화면으로 이동
      },
    );
  }

  // 결제 수단 섹션
  Widget _buildPaymentMethods() {
    return ListTile(
      title: Text(
        '결제 수단',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        // 결제 수단 화면으로 이동
      },
    );
  }

  // 현금 영수증 섹션
  Widget _buildReceiptSection() {
    return ListTile(
      title: Text(
        '현금영수증',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        // 현금영수증 화면으로 이동
      },
    );
  }

  // 총 금액 표시
  Widget _buildTotalPriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('총 금액: ', style: TextStyle(fontSize: 16)),
        Text('${calculateTotalPrice()}원', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // 결제 버튼
  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // 결제하기 동작 추가
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown, // 버튼 색상
        ),
        child: Text('${calculateTotalPrice()}원 결제하기', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: PaymentScreen(),
));
