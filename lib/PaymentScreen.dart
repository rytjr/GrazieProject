import 'package:flutter/material.dart';
import 'package:fluttertest/CashScreen.dart';
import 'package:fluttertest/HomeScrean.dart';
import 'package:fluttertest/PaymentWebView.dart';
import 'package:fluttertest/SecureStorageService.dart';
import 'package:fluttertest/impart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Timer를 사용하기 위해 추가합니다.

class PaymentScreen extends StatefulWidget {
  final dynamic product;
  final String storeId;
  final String orderOption;
  final int quantity;
  final String selectedCup;
  final String? specialRequest;
  final String tk;
  final int keypoint;
  final int orderprice;
  final String onename;

  PaymentScreen({
    required this.product,
    required this.storeId,
    required this.orderOption,
    required this.quantity,
    required this.selectedCup,
    this.specialRequest,
    required this.tk,
    required this.keypoint,
    required this.orderprice,
    required this.onename,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<dynamic> orders = [];
  bool _isExpanded = false;
  bool isLoading = true;
  String? selectedCouponId;
  String orderId = '';
  String impuid = '';
  int finalPrice = 0;
  String name = '';
  String phone = '';
  String email = '';
  Timer? _collapseTimer; // 자동으로 닫히도록 하는 Timer

  @override
  void initState() {
    super.initState();
    if (widget.keypoint == 1) {
      fetchOrderData();
    } else {
      setState(() {
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
    fetchUserInfo();
  }

  Future<void> fetchOrderData() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();

    final response = await http.get(
      Uri.parse('http://34.64.110.210:8080/cart/items'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        orders = jsonDecode(utf8.decode(response.bodyBytes));
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load orders');
    }
  }

  Future<void> fetchUserInfo() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();

    final response = await http.get(
      Uri.parse('http://34.64.110.210:8080/users/readProfile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        name = data['name'];
        phone = data['phone'];
        email = data['email'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load profile');
    }
  }

  int calculateTotalPrice() {
    return orders.fold(0, (int sum, item) => sum + ((item['price'] ?? 0) as num).toInt());
  }

  Future<void> sendPaymentProgress() async {
    if (impuid.isEmpty || orderId.isEmpty) {
      print("Error: imp_uid or orderId is empty.");
      return;
    }

    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();

    final url = Uri.parse(
        'http://34.64.110.210:8080/api/pay/progress?imp_uid=$impuid&orderId=$orderId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("결제 진행 결과 : ${response.body}");
      if (response.statusCode == 200) {
        print('Payment progress sent successfully.');
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen()),
        );
      } else {
        print('Failed to send payment progress.');
      }
    } catch (e) {
      print('Error sending payment progress: $e');
    }
  }

  Map<String, dynamic> createOrderData() {
    List<Map<String, dynamic>> items = orders.map((item) {
      final personalOptions = item['personalOptions'] ?? {};
      final concentration = personalOptions['concentration'] == "medium"
          ? "NORMAL"
          : personalOptions['concentration'] ?? "NORMAL";

      int convertBoolToInt(dynamic value) => value == true ? 1 : 0;
      print('하나 가격 : ${item['price']}');
      int getDisplayPrice() {
        int itemPrice = item['price'] ?? 0;
        return itemPrice > 0 ? itemPrice : calculateTotalPrice();
      }
      finalPrice = calculateTotalPrice();
      return {
        "productId": item['productId'] ?? 1,
        "productPrice": getDisplayPrice(),
        "quantity": item['quantity'] ?? 1,
        "size": item['size'] ?? "Solo",
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
      };
    }).toList();

    return {
      "orderCreateDTO": {
        "order_date": DateTime.now().toIso8601String(),
        "order_mode": widget.orderOption,
        "requirement": widget.specialRequest ?? '',
        "store_id": int.parse(widget.storeId),
      },
      "orderItemsCreateDTOS": items,
    };
  }

  Future<void> submitOrder() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();

    final url = 'http://34.64.110.210:8080/api/order/create';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(createOrderData()),
      );
      print("오더 생서 : ${response.body}");
      print(response.request);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        orderId = responseData['orderId'].toString();
        finalPrice = calculateTotalPrice();
      } else {
        print('Order submission failed: ${response.body}');
      }
    } catch (e) {
      print('Error during order submission: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('결제하기'),
      ),
      body: Stack(
        children: [
          isLoading
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
                      itemBuilder: (context, index) =>
                          _buildOrderItem(orders[index]),
                      separatorBuilder: (context, index) =>
                          Divider(thickness: 1, color: Colors.grey[300]),
                    ),
                  ),
                _buildCouponSection(),
                Divider(thickness: 1, color: Colors.grey[300]),
              ],
            ),
          ),
          Positioned(
            bottom: 110,
            left: 16,
            right: 16,
            child: _buildTotalPriceRow(),
          ),
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: _buildPaymentButton(),
          ),
          Positioned(
            bottom: 150,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () {
                // FAB를 눌렀을 때의 액션 추가
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => HomeScreen()), // 회원정보 수정 화면으로 이동
                );
              },
              child: Icon(Icons.home, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('주문 내역', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Divider(thickness: 2, color: Colors.grey[300]),
        Container(
          constraints: BoxConstraints(maxHeight: 200),
          child: ListView.separated(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemCount: orders.length,
            itemBuilder: (context, index) => _buildOrderItem(orders[index]),
            separatorBuilder: (context, index) => Divider(thickness: 1, color: Colors.grey[300]),
          ),
        ),
      ],
    );
  }

  // Helper method to show a Dialog with personalOptions details
  void _showPersonalOptionsDialog(Map<String, dynamic> personalOptions) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("개인 맞춤 옵션", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOptionRow("농도", personalOptions['concentration'] ?? "N/A"),
              _buildOptionRow("샷 추가", personalOptions['shotAddition'] == 1 ? "Yes" : "No"),
              _buildOptionRow("개인 텀블러 사용", personalOptions['personalTumbler'] == "USE" ? "Yes" : "No"),
              _buildOptionRow("펄 추가", personalOptions['pearlAddition'] == 1 ? "Yes" : "No"),
              _buildOptionRow("시럽 추가", personalOptions['syrupAddition'] == 1 ? "Yes" : "No"),
              _buildOptionRow("설탕 추가", personalOptions['sugarAddition'] == 1 ? "Yes" : "No"),
              _buildOptionRow("휘핑 추가", personalOptions['whippedCreamAddition'] == 1 ? "Yes" : "No"),
              _buildOptionRow("얼음 양", personalOptions['iceAddition'] ?? "N/A"),
            ],
          ),
          actions: [
            TextButton(
              child: Text("닫기", style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 16, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    final personalOptions = item['personalOptions'] ?? {};
    final temperature = item['temperature'] == 'ice' ? 'Ice' : 'Hot';
    final cupType = personalOptions['personalTumbler'] == 'USE' ? '개인 텀블러' : '일회용 컵';

    return GestureDetector(
      onTap: () {
        if (personalOptions.isNotEmpty) {
          _showPersonalOptionsDialog(personalOptions); // personalOptions 정보를 보여주는 Dialog 호출
        }
      },
      child: Row(
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
                Text(item['productName'] ?? widget.onename, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('$temperature / $cupType', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text('수량: ${item['quantity'] ?? 0}', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${(item['price'] ?? 0)}원', style: TextStyle(fontSize: 16, color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildCouponSection() {
    return ListTile(
      title: Text('Coupon 사용', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () async {
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
            selectedCouponId = selectedCoupon;
          });
        }
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
          await submitOrder();
          await Future.delayed(Duration(seconds: 1));
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => impart(finalPrice: finalPrice, name: name, phone: phone, email: email),
            ),
          );
          impuid = result['imp_uid'];
          sendPaymentProgress();
        },
        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF5B1333)),
        child: Text('${calculateTotalPrice()}원 결제하기', style: TextStyle(fontSize: 18, color: Colors.white)),
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
  String? selectedCouponId; // 하나만 선택 가능

  @override
  void initState() {
    super.initState();
    fetchCouponsData();
  }

  Future<void> fetchCouponsData() async {
    setState(() => isLoading = true);
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();

    try {
      final response = await http.get(
        Uri.parse('http://34.64.110.210:8080/api/coupons/issued-list'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("쿠폰 목록 : ${jsonDecode(utf8.decode(response.bodyBytes))}");
      if (response.statusCode == 200) {
        setState(() {
          coupons = jsonDecode(utf8.decode(response.bodyBytes));
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load coupons');
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
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
            onPressed: () => Navigator.pop(context, selectedCouponId),
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
                  isSelected: selectedCouponId == coupons[index]['id'].toString(),
                  onSelected: (couponId) {
                    setState(() {
                      selectedCouponId = selectedCouponId == couponId ? null : couponId;
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
                if (selectedCouponId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('쿠폰을 선택해주세요.')),
                  );
                } else {
                  Navigator.pop(context, selectedCouponId);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF5B1333),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text('사용하기', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class CouponCard extends StatelessWidget {
  final dynamic coupon;
  final bool isSelected;
  final ValueChanged<String> onSelected;

  const CouponCard({
    required this.coupon,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(coupon['id'].toString()), // 선택 시 콜백 실행
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.shade300),
        ),
        color: isSelected ? Colors.blue.shade50 : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${coupon['couponName']} 쿠폰', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('${coupon['description']}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              SizedBox(height: 8),
              Text('기간 ${coupon['expirationDate']}', style: TextStyle(fontSize: 14, color: Colors.red)),
              SizedBox(height: 8),
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
