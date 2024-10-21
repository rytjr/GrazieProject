import 'package:flutter/material.dart';
import 'package:fluttertest/CashScreen.dart';
import 'package:fluttertest/PaymentWebView.dart';
import 'package:fluttertest/SecureStorageService.dart';
import 'package:fluttertest/impart.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 토큰 저장/가져오기 위한 패키지
import 'dart:convert';

class PaymentScreen extends StatefulWidget {
  final dynamic product;
  final String storeId;  // 매장 ID
  final String orderOption;  // 매장이용 or To-Go
  final int quantity;
  final String selectedCup;
  final String? specialRequest; // 요구사항 추가

  PaymentScreen({
    required this.product,
    required this.storeId,
    required this.orderOption,
    required this.quantity,
    required this.selectedCup,
    this.specialRequest, // optional 매개변수로 추가
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<dynamic> orders = [];
  bool _isExpanded = false;
  bool isLoading = true;
  late String pageUrl;
  String? selectedCouponId; // 선택된 쿠폰 ID

  @override
  void initState() {
    super.initState();
    fetchOrderData();
  }

  Future<void> fetchOrderData() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    final response = await http.get(
      Uri.parse('http://34.64.110.210:8080/cart/items'),
      headers: {
        'Authorization': 'Bearer $token'
      },
    );
    print('order' + response.body);
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

  int calculateTotalPrice() {
    return orders.fold(0, (sum, item) => sum + (item['price'] as int? ?? 0) * (item['quantity'] as int? ?? 0));
  }

  Future<void> checkPaymentProgress(String impUid) async {
    final url = 'http://34.64.110.210:8080/api/pay/progress/$impUid';  // imp_uid를 URL에 추가

    try {
      final response = await http.post(Uri.parse(url));  // POST 요청 보내기

      if (response.statusCode == 200) {
        // 요청이 성공한 경우 처리
        print('결제 진행 상태: ${response.body}');
      } else {
        // 요청이 실패한 경우 처리
        print('결제 진행 상태 확인 실패: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      // 예외 처리
      print('오류 발생: $e');
    }
  }

  // 결제 요청을 보내는 메서드
  Future<void> _makePayment() async {
    try {
      // API로 GET 요청을 보냄
      final response = await http.get(
        Uri.parse('http://34.64.110.210:8080/api/pay/page'),  // 요청할 URL로 변경
      );

      if (response.statusCode == 200) {
        final pageUrl = response.body; // 응답에서 반환된 URL을 받아옴
        print('받아온 url : ${pageUrl}');
        _showPaymentWebView(pageUrl); // WebView로 페이지 열기
      } else {
        // 결제 실패 처리
        print('결제 실패: ${response.body}');
        _showErrorDialog('결제에 실패했습니다. 다시 시도해 주세요.');
      }
    } catch (e) {
      print('오류가 발생했습니다: $e');
      _showErrorDialog('결제 요청 중 오류가 발생했습니다.');
    }
  }

  // 결제 페이지를 WebView로 열기
  void _showPaymentWebView(String pageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('결제 페이지'),
          ),
          body: WebView(
            initialUrl: pageUrl, // 반환된 페이지 URL을 WebView에 로드
            javascriptMode: JavascriptMode.unrestricted, // 자바스크립트 허용
          ),
        ),
      ),
    );
  }

  // 주문 데이터를 생성하는 메서드
  Map<String, dynamic> createOrderData() {
    return {
      "orderCreateDTO": {
        "order_date": DateTime.now().toIso8601String(),
        "order_mode": widget.orderOption,
        "requirement": widget.specialRequest ?? '',
        "store_id": int.parse(widget.storeId),
        "user_id": 1, // 예시로 사용자 ID를 1로 설정
      },
      "orderItemsCreateDTOS": orders.map((order) {
        final personalOptions = order['personalOptions'];
        return {
          "productId": order['productId'] ?? 0,
          "productPrice": order['price'],
          "quantity": order['quantity'],
          "size": order['size'],
          "temperature": order['temperature'],
          "couponId": selectedCouponId != null ? int.parse(selectedCouponId!) : 0, // 선택된 쿠폰 ID
          "concentration": personalOptions['concentration'],
          "shotAddition": personalOptions['shotAddition'],
          "personalTumbler": personalOptions['personalTumbler'],
          "pearlAddition": personalOptions['pearlAddition'],
          "syrupAddition": personalOptions['syrupAddition'],
          "sugarAddition": personalOptions['sugarAddition'],
          "whippedCreamAddition": personalOptions['whippedCreamAddition'],
          "iceAddition": personalOptions['iceAddition']
        };
      }).toList(),
    };
  }

  // 주문 생성 API 호출
  Future<void> submitOrder() async {
    try {
      SecureStorageService storageService = SecureStorageService();
      String? token = await storageService.getToken();

      final url = 'http://34.64.110.210:8080/api/order/create';
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = jsonEncode(createOrderData());
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        print('주문 성공: ${response.body}');
        // 주문 성공 처리 로직 추가
      } else {
        print('주문 실패: ${response.statusCode}, ${response.body}');
        _showErrorDialog('주문에 실패했습니다. 다시 시도해 주세요.');
      }
    } catch (e) {
      print('오류 발생: $e');
      _showErrorDialog('주문 중 오류가 발생했습니다.');
    }
  }

  // 결제 실패 다이얼로그
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('결제 실패'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('결제하기'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
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
            Divider(thickness: 2, color: Colors.grey[300]),
            _buildOrderSummary(),
            Divider(thickness: 1, color: Colors.grey[300]),
            if (_isExpanded)
              Expanded(
                child: ListView.separated(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return _buildOrderItem(orders[index]);
                  },
                  separatorBuilder: (context, index) => Divider(thickness: 1, color: Colors.grey[300]),
                ),
              ),
            Divider(thickness: 1, color: Colors.grey[300]),
            _buildCouponSection(),
            Divider(thickness: 1, color: Colors.grey[300]),
            _buildPaymentMethods(),
            Divider(thickness: 1, color: Colors.grey[300]),
            _buildReceiptSection(),
            SizedBox(height: 20),
            _buildTotalPriceRow(),
            SizedBox(height: 10),
            _buildPaymentButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    var firstItem = orders.isNotEmpty ? orders[0] : null;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
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
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(firstItem['name'] ?? '상품 이름 없음', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('${firstItem['price'] ?? 0}원', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    Text('${firstItem['size'] ?? ''} / ${firstItem['cup'] ?? ''}', style: TextStyle(fontSize: 14, color: Colors.grey)),
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

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.network(
          item['image'] ?? '',
          width: 50,
          height: 50,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['name'] ?? '상품 이름 없음', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('${item['size'] ?? ''} / ${item['cup'] ?? ''}', style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text('수량: ${item['quantity'] ?? 0}', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${item['price'] ?? 0}원', style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text('${(item['price'] ?? 0) * (item['quantity'] ?? 0)}원', style: TextStyle(fontSize: 16, color: Colors.black)),
          ],
        ),
      ],
    );
  }

  Widget _buildCouponSection() {
    return ListTile(
      title: Text(
        'Coupon 사용',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () async {
        // 쿠폰 사용 모달창 표시하고 선택한 쿠폰의 ID 받기
        final selectedCoupon = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return FractionallySizedBox(
              heightFactor: 0.9,
              child: CouponModal(),
            );
          },
        );

        if (selectedCoupon != null) {
          setState(() {
            selectedCouponId = selectedCoupon; // 선택된 쿠폰 ID 저장
          });
        }
      },
    );
  }

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

  Widget _buildReceiptSection() {
    return ListTile(
      title: Text(
        '현금영수증',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        // 현금영수증 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CashScreen()),
        );
      },
    );
  }

  Widget _buildTotalPriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('총 금액: ', style: TextStyle(fontSize: 16)),
        Text('${calculateTotalPrice()}원', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          // 결제 화면을 호출하고 결제 결과를 받음
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => impart(),
            ),
          );
          // 결제 결과 처리
          if (result != null) {
            print("imp" + result);
            final impUid = result['imp_uid'];
            checkPaymentProgress(impUid);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown,
        ),
        child: Text('${calculateTotalPrice()}원 결제하기', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

// 쿠폰 모달 화면
class CouponModal extends StatefulWidget {
  @override
  _CouponModalState createState() => _CouponModalState();
}

class _CouponModalState extends State<CouponModal> {
  List<dynamic> coupons = [];
  List<dynamic> orders = []; // orders 변수 선언
  bool isLoading = true;
  String? selectedCouponId; // 선택된 쿠폰 ID를 저장하는 변수

  @override
  void initState() {
    super.initState();
    fetchOrderData(); // 바로 비동기 호출을 할 수 있도록 변경
  }

  Future<void> fetchOrderData() async {
    setState(() {
      isLoading = true;
    });

    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    print(token);
    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('http://34.64.110.210:8080/cart/items'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
        print('order' + response.body);

        if (response.statusCode == 200) {
          setState(() {
            orders = json.decode(response.body);
            isLoading = false;
          });
        } else {
          throw Exception('Failed to load orders');
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          isLoading = false;
        });
      }
    } else {
      // 토큰이 없을 경우 처리 (로그아웃 상태)
      print("No token found");
      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('쿠폰 선택'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, selectedCouponId); // 선택된 쿠폰 ID 반환
            },
            child: Text('선택 완료', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: coupons.length,
        itemBuilder: (context, index) {
          return CouponCard(
            coupon: coupons[index],
            isSelected: selectedCouponId == coupons[index]['id'],
            onSelected: (String couponId) {
              setState(() {
                selectedCouponId = couponId; // 선택된 쿠폰 ID 업데이트
              });
            },
          );
        },
      ),
    );
  }
}

class CouponCard extends StatelessWidget {
  final dynamic coupon;
  final bool isSelected; // 선택 여부
  final ValueChanged<String> onSelected;

  const CouponCard({
    required this.coupon,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onSelected(coupon['id']); // 쿠폰이 선택되면 ID 반환
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.shade300), // 선택된 쿠폰 강조
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${coupon['name']} 쿠폰',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '${coupon['description']}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              SizedBox(height: 8),
              Text(
                '기간 ${coupon['expirationDate']}',
                style: TextStyle(fontSize: 14, color: Colors.red),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  home: PaymentScreen(
    product: {'product_id': 1, 'name': '커피', 'price': 5000, 'image': 'image_url'},  // 예시 데이터
    storeId: '1',
    orderOption: '매장이용',
    quantity: 1,
    selectedCup: 'Solo',
  ),
));
