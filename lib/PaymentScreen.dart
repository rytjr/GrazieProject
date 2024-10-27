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
  final String tk;
  final int keypoint;
  final int orderprice;

  PaymentScreen({
    required this.product,
    required this.storeId,
    required this.orderOption,
    required this.quantity,
    required this.selectedCup,
    this.specialRequest, // optional 매개변수로 추가
    required this.tk,
    required this.keypoint,
    required this.orderprice,
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
  String orderId = '';
  String impuid = '';
  int finlaprice = 0;
  String name = '';
  String phone = '';
  String email = '';
  @override
  void initState() {
    super.initState();
    print("키포인트 ${widget.keypoint}");
    if (widget.keypoint == 1) {
      fetchOrderData();
    } else {
      // keypoint가 1이면 넘겨받은 데이터로 주문 내역 설정
      setState(() {
        print('가격 ${widget.product}');
        orders = [
          {
            'name': widget.product['name'],
            'price': widget.orderprice,
            'quantity': widget.quantity,
            'image': widget.product['image'],
            'size': widget.selectedCup,
            'cup': widget.selectedCup,
          }
        ];
        isLoading = false;
      });
    }
    fetchGetName();
  }

  Future<void> fetchOrderData() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    print('tttkkk : $token');
    final response = await http.get(
      Uri.parse('http://34.64.110.210:8080/cart/items'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
        },
    );
    final decodedResponseBody = utf8.decode(response.bodyBytes);

    print('orderr : ' + decodedResponseBody);
    if (response.statusCode == 200) {
      setState(() {
        orders = jsonDecode(decodedResponseBody);
        isLoading = false;
      });
      print("카트결과 : $orders");
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load orders');
    }
  }

  Future<void> fetchGetName() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    print("제발2 $token");
    final response = await http.get(
      Uri.parse('http://34.64.110.210:8080/users/readProfile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );
    final decodedResponseBody = utf8.decode(response.bodyBytes);

    print('ordname : ' + decodedResponseBody);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(decodedResponseBody);
      setState(() {
        name = data['name'];
        phone = data['phone'];
        email = data['email'];
        isLoading = false;
      });
      print(name);
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load orders');
    }
  }

  int calculateTotalPrice() {
    return orders.fold(0, (sum, item) => sum + (item['price'] as int? ?? 0));
  }


  Future<void> sendPaymentProgress() async {
    if (impuid.isEmpty || orderId.isEmpty) {
      print("오류: imp_uid 또는 orderId가 비어 있습니다.");
      return;
    }

    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();

    final int parsedOrderId = int.tryParse(orderId) ?? 0;

    final url = Uri.parse('http://34.64.110.210:8080/api/pay/progress?imp_uid=$impuid&orderId=$parsedOrderId');

    print('Request URL: $url');
    print('Request Headers: Content-Type: application/json, Authorization: Bearer $token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('결제 진행 상태 전송 성공: ${response.body}');
      } else {
        print('결제 진행 상태 전송 실패: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      print('결제 진행 상태 전송 중 오류 발생: $e');
    }
  }



  // 주문 데이터를 생성하는 메서드
  Map<String, dynamic> createOrderData() {
    final product = widget.product;
    final personalOptions = product['personalOptions'] ?? {};

    final concentration = personalOptions['concentration'] == "medium"
        ? "NORMAL"
        : personalOptions['concentration'] ?? "NORMAL";

    // boolean 값을 int로 변환하는 함수
    int convertBoolToInt(dynamic value) => value == true ? 1 : 0;

    return {
      "orderCreateDTO": {
        "order_date": DateTime.now().toIso8601String(),
        "order_mode": widget.orderOption,
        "requirement": widget.specialRequest ?? '',
        "store_id": 1,
      },
      "orderItemsCreateDTOS": [
        {
          "productId": product['productId'] ?? 1,
          "productPrice": widget.orderprice,
          "quantity": widget.quantity,
          "size": widget.selectedCup,
          "temperature": personalOptions['temperature'] ?? "hot",
          "couponId": selectedCouponId != null ? int.parse(selectedCouponId!) : null,
          "concentration": concentration,
          "shotAddition": convertBoolToInt(personalOptions['shotAddition']),
          "personalTumbler": convertBoolToInt(personalOptions['personalTumbler']),
          "pearlAddition": convertBoolToInt(personalOptions['pearlAddition']),
          "syrupAddition": convertBoolToInt(personalOptions['syrupAddition']),
          "sugarAddition": convertBoolToInt(personalOptions['sugarAddition']),
          "whippedCreamAddition": convertBoolToInt(personalOptions['whippedCreamAddition']),
          "iceAddition": convertBoolToInt(personalOptions['iceAddition']),
        }
      ],
    };
  }



  // 주문 생성 API 호출
  Future<void> submitOrder() async {
    try {
      SecureStorageService storageService = SecureStorageService();
      String? token = await storageService.getToken();
      print('tttkkk1 : $token');
      final url = 'http://34.64.110.210:8080/api/order/create';

      final body = jsonEncode(createOrderData());
      print('주문 생성 보내는거  $body');
      final response = await http.post(
        Uri.parse(url),
      headers: {
          'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
        },
      body: body, // 데이터를 JSON으로 변환하여 전송
      );
      print('ordermake $body');
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('주문 성공: ${response.body}');

        // 서버에서 반환된 orderId 저장
        orderId = responseData['orderId'].toString();
        finlaprice = responseData['finalPrice'];

        // 주문 성공 후 결제 진행
        // await startPaymentProcess();
      } else {
        print('주문 실패: ${response.statusCode}, ${response.body}');
        // _showErrorDialog('주문에 실패했습니다. 다시 시도해 주세요.');
      }
    } catch (e) {
      print('오류 발생: $e');
      // _showErrorDialog('주문 중 오류가 발생했습니다.');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드 올라와도 버튼 고정
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('결제하기'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            _buildCouponSection(),
            Divider(thickness: 1, color: Colors.grey[300]),
            // _buildPaymentMethods(),
            // Divider(thickness: 1, color: Colors.grey[300]),
            // _buildReceiptSection(),
            // SizedBox(height: 20),
            SizedBox(height: 300),
            _buildTotalPriceRow(),
            SizedBox(height: 10),

            _buildPaymentButton(),
          ],
        ),
      ),
    );
  }
  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '주문 내역',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Divider(thickness: 2, color: Colors.grey[300]),
        Container(
          constraints: BoxConstraints(
            maxHeight: 200, // 전체 리스트의 최대 높이 설정
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(), // 스크롤 가능하게 설정
            itemCount: orders.length, // 전체 리스트 크기
            itemBuilder: (context, index) {
              var item = orders[index];
              return _buildOrderItem(item); // 항목 빌드
            },
            separatorBuilder: (context, index) => Divider(thickness: 1, color: Colors.grey[300]),
          ),
        ),
      ],
    );
  }


  Widget _buildOrderItem(Map<String, dynamic> item) {
    final personalOptions = item['personalOptions'] ?? {};
    final temperature = item['temperature'] == 'ice' ? 'Ice' : 'Hot';
    final cupType = personalOptions['personalTumbler'] == 'NOT_USE' ? '일회용컵' : '개인용 컵';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.network(
          'http://34.64.110.210:8080/' + (item['image'] ?? ''),
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
              Text('$temperature / $cupType', style: TextStyle(fontSize: 14, color: Colors.grey)),
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
            // submitOrder();
            print("선택된 쿠폰 $selectedCouponId");
          });
        }

      },
    );
  }

  // Widget _buildPaymentMethods() {
  //   return ListTile(
  //     title: Text(
  //       '결제 수단',
  //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //     ),
  //     trailing: Icon(Icons.arrow_forward_ios),
  //     onTap: () {
  //       // 결제 수단 화면으로 이동
  //     },
  //   );
  // }

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
    submitOrder();
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () async {
          submitOrder();
          await Future.delayed(Duration(seconds: 1));
          // 결제 화면을 호출하고 결제 결과를 받음
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => impart(finalprice:  finlaprice, name: name, phone: phone, email: email),
            ),
          );
          // 결제 결과 처리
          print('result22 $result');

          impuid = result['imp_uid'];
          // checkPaymentProgress(impUid);


          sendPaymentProgress();

        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF5B1333),
        ),
        child: Text('${calculateTotalPrice()}원 결제하기', style: TextStyle(fontSize: 18,color: Colors.white)),
      ),
    );
  }
}
class CouponModal extends StatefulWidget {
  @override
  _CouponModalState createState() => _CouponModalState();
}

class _CouponModalState extends State<CouponModal> {
  List<dynamic> coupons = [];
  bool isLoading = true;
  String? selectedCouponId; // 선택된 쿠폰 ID를 저장하는 변수

  @override
  void initState() {
    super.initState();
    fetchCouponsData(); // 비동기로 쿠폰 데이터를 가져오는 함수 호출
  }

  Future<void> fetchCouponsData() async {
    setState(() {
      isLoading = true;
    });

    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    print(token);

    try {
      final response = await http.get(
        Uri.parse('http://34.64.110.210:8080/api/coupons/issued-list'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      final decodedResponseBody = utf8.decode(response.bodyBytes);

      print('응답 받은 쿠폰 리스트: $decodedResponseBody');
      if (response.statusCode == 200) {
        setState(() {
          coupons = jsonDecode(decodedResponseBody);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load coupons');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('쿠폰 선택'),
        actions: [
          TextButton(
            onPressed: () {
              // 선택된 쿠폰 ID를 반환하고 모달 닫기
              Navigator.pop(context, selectedCouponId);
            },
            child: Text('선택 완료', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: coupons.length,
              itemBuilder: (context, index) {
                return CouponCard(
                  coupon: coupons[index],
                  // 쿠폰 ID가 null이 아닌 경우에만 비교. 형 변환을 통해 일관성 유지.
                  isSelected: selectedCouponId == coupons[index]['id'].toString(),
                  onSelected: (String couponId) {
                    setState(() {
                      selectedCouponId = couponId; // 선택된 쿠폰 ID 업데이트
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // 선택된 쿠폰이 없는 경우 처리
                if (selectedCouponId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('쿠폰을 선택해주세요.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  // 선택된 쿠폰 ID를 반환하고 모달 닫기
                  Navigator.pop(context, selectedCouponId);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5B1333), // 버튼 색상 설정
                minimumSize: Size(double.infinity, 50), // 버튼 크기 설정
              ),
              child: Text('사용하기', style: TextStyle(fontSize: 18,color: Colors.white)),
            ),
          ),
        ],
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
        // 쿠폰 선택 시 ID를 문자열로 변환하여 전달
        onSelected(coupon['id'].toString()); // 쿠폰이 선택되면 ID 반환
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
                '${coupon['couponName']} 쿠폰',
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
              SizedBox(height: 8),
              Text(
                '발급 가능 기간 ${coupon['issueDate']}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
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
    tk: '1',
    keypoint: 0,
    orderprice: 0,
  ),
));
