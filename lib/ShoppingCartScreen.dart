import 'package:flutter/material.dart';
import 'package:fluttertest/PaymentScreen.dart';
import 'package:fluttertest/SecureStorageService.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class ShoppingCartScreen extends StatefulWidget {
  final String orderoption;
  final String storeId;

  ShoppingCartScreen({required this.orderoption, required this.storeId});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<ShoppingCartScreen> {
  List<dynamic> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    final response = await http.get(
      Uri.parse('http://34.64.110.210:8080/cart/items'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    final decodedResponseBody = utf8.decode(response.bodyBytes);
    print("쇼핑 : $decodedResponseBody");
    if (response.statusCode == 200) {
      setState(() {
        cartItems = jsonDecode(decodedResponseBody);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load cart items');
    }
  }

  Future<void> increaseQuantity(int index) async {
    setState(() {
      cartItems[index]['quantity']++;
    });

    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    final response = await http.patch(
      Uri.parse('http://34.64.110.210:8080/cart/increaseQuantity'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'cartItemId': cartItems[index]['productId'].toString(),
      }),
    );
    print("증가 요청 상태 코드: ${response.statusCode}");
    print("증가 요청 응답 본문: ${response.body}");
  }

  Future<void> decreaseQuantity(int index) async {
    if (cartItems[index]['quantity'] > 1) {
      setState(() {
        cartItems[index]['quantity']--;
      });

      SecureStorageService storageService = SecureStorageService();
      String? token = await storageService.getToken();
      final response = await http.patch(
        Uri.parse('http://34.64.110.210:8080/cart/decreaseQuantity'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'cartItemId': cartItems[index]['productId'].toString(),
        }),
      );

      print("감소 요청 상태 코드: ${response.statusCode}");
      print("감소 요청 응답 본문: ${response.body}");
    }
  }

  Future<void> deleteItem(int index) async {
    final cartItemId = cartItems[index]['productId'];

    if (cartItemId == null) {
      print('삭제 실패: cartItemId가 null입니다.');
      return;
    }

    setState(() {
      cartItems.removeAt(index);
    });

    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();

    final response = await http.delete(
      Uri.parse('http://34.64.110.210:8080/cart/delete'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'cartItemId': cartItemId.toString(),
      }),
    );

    print('삭제 요청 상태 코드: ${response.statusCode}');
    print('삭제 요청 응답 본문: ${response.body}');
  }

  int calculateTotalPrice() {
    return cartItems.fold<int>(0, (int sum, item) {
      int price = (item['price'] ?? 0) as int;
      int quantity = (item['quantity'] ?? 1) as int;
      return sum + price * quantity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('장바구니'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '다산 그라찌에 (${widget.orderoption})',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Divider(thickness: 2, color: Colors.grey[300]),
            Expanded(
              child: ListView.separated(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  return _buildCartItem(cartItems[index], index);
                },
                separatorBuilder: (context, index) => Divider(thickness: 1, color: Colors.grey[300]),
              ),
            ),
            SizedBox(height: 20),
            _buildTotalPriceRow(),
            SizedBox(height: 20),
            _buildOrderButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    final personalOptions = item['personalOptions'] ?? {};
    final temperature = item['temperature'] == 'ice' ? 'Ice' : 'Hot';
    final cupType = personalOptions['personalTumbler'] == 'NOT_USE' ? '일회용컵' : '개인용 컵';

    return GestureDetector(
      onTap: () {
        _showPersonalOptionsDialog(personalOptions);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            item['image'] != null ? 'http://34.64.110.210:8080/' + item['image'] : 'https://via.placeholder.com/50',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['productName'] ?? '상품 이름 없음', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('$temperature / $cupType', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => decreaseQuantity(index),
                      icon: Icon(Icons.remove_circle_outline, size: 20),
                    ),
                    Text('${item['quantity'] ?? 1}', style: TextStyle(fontSize: 16)),
                    IconButton(
                      onPressed: () => increaseQuantity(index),
                      icon: Icon(Icons.add_circle_outline, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${(item['price'] ?? 0)}원', style: TextStyle(fontSize: 16, color: Colors.black)),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () => deleteItem(index),
                child: Text(
                  '삭제하기',
                  style: TextStyle(fontSize: 14, color: Color(0xFF5B1333)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 개인 맞춤 옵션을 모달로 표시
  void _showPersonalOptionsDialog(Map<String, dynamic> options) {
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
              _buildOptionRow("농도", options['concentration'] ?? "N/A"),
              _buildOptionRow("샷 추가", options['shotAddition'] == 1 ? "Yes" : "No"),
              _buildOptionRow("개인 텀블러 사용", options['personalTumbler'] == "USE" ? "Yes" : "No"),
              _buildOptionRow("펄 추가", options['pearlAddition'] == 1 ? "Yes" : "No"),
              _buildOptionRow("시럽 추가", options['syrupAddition'] == 1 ? "Yes" : "No"),
              _buildOptionRow("설탕 추가", options['sugarAddition'] == 1 ? "Yes" : "No"),
              _buildOptionRow("휘핑 추가", options['whippedCreamAddition'] == 1 ? "Yes" : "No"),
              _buildOptionRow("얼음 양", options['iceAddition'] ?? "N/A"),
            ],
          ),
          actions: [
            TextButton(
              child: Text("확인", style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildTotalPriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('총 ${cartItems.length}개  ', style: TextStyle(fontSize: 16)),
        Text('${calculateTotalPrice()}원', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PaymentScreen(
                  product: [],
                  storeId: widget.storeId,
                  orderOption: widget.orderoption,
                  quantity: 1,
                  selectedCup: 'NOT USE',
                  specialRequest: '',
                  tk: '',
                  keypoint: 1,
                  orderprice: 0,
                  onename: '',
                )),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF5B1333),
        ),
        child: Text('${calculateTotalPrice()}원 주문하기', style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: ShoppingCartScreen(orderoption: '매장 이용', storeId: '2'),
));
