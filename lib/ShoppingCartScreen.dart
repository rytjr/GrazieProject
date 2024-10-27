import 'package:flutter/material.dart';
import 'package:fluttertest/SecureStorageService.dart';
import 'package:fluttertest/PaymentScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShoppingCartScreen extends StatefulWidget {
  final String orderoption;

  ShoppingCartScreen({
    required this.orderoption,
  });
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<ShoppingCartScreen> {
  List<dynamic> cartItems = [];
  List<bool> isSelectedList = [];
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
    if (response.statusCode == 200) {
      setState(() {
        cartItems = jsonDecode(decodedResponseBody);
        isSelectedList = List<bool>.filled(cartItems.length, false);
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
    print("증가토큰 : $token");
    final response = await http.patch(
      Uri.parse('http://34.64.110.210:8080/cart/increaseQuantity'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'cartItemId': cartItems[index]['cartItemId'].toString(),
      }),
    );
    print("이유 : ${response.body}");
    if (response.statusCode == 200) {
      print('Quantity increased successfully');
    } else {
      print('Failed to increase quantity: ${response.statusCode}');
    }
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
          'cartItemId': cartItems[index]['cartItemId'].toString(),
        }),
      );
      print("이유 ${response.body}");
      if (response.statusCode == 200) {
        print('Quantity decreased successfully');
      } else {
        print('Failed to decrease quantity: ${response.statusCode}');
      }
    }
  }

  int calculateTotalSelectedPrice() {
    int total = 0;
    for (int i = 0; i < cartItems.length; i++) {
      if (isSelectedList[i]) {
        total += (cartItems[i]['price'] as int) * (cartItems[i]['quantity'] as int);
      }
    }
    return total;
  }

  int calculateTotalSelectedItems() {
    int total = 0;
    for (int i = 0; i < isSelectedList.length; i++) {
      if (isSelectedList[i]) {
        total++;
      }
    }
    return total;
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
            _buildHeaderRow(),
            Divider(thickness: 1, color: Colors.grey[300]),
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

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: isSelectedList.every((isSelected) => isSelected),
              onChanged: (bool? value) {
                setState(() {
                  isSelectedList = List<bool>.filled(cartItems.length, value ?? false);
                });
              },
            ),
            Text('전체 선택'),
          ],
        ),
        TextButton(
          onPressed: deleteSelectedItems,
          child: Text('선택 삭제', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    final personalOptions = item['personalOptions'] ?? {};
    final temperature = item['temperature'] == 'ice' ? 'Ice' : 'Hot';
    final cupType = personalOptions['personalTumbler'] == 'NOT_USE' ? '일회용컵' : '개인용 컵';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: isSelectedList[index],
          onChanged: (bool? value) {
            setState(() {
              isSelectedList[index] = value ?? false;
            });
          },
        ),
        SizedBox(width: 10),
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
              Row(
                children: [
                  Text('$temperature / $cupType', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  SizedBox(width: 10),
                ],
              ),
              Text('옵션변경', style: TextStyle(fontSize: 14, color: Colors.black)),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      decreaseQuantity(index);
                    },
                    icon: Icon(Icons.remove_circle_outline, size: 20),
                  ),
                  Text('${item['quantity'] ?? 1}', style: TextStyle(fontSize: 16)),
                  IconButton(
                    onPressed: () {
                      increaseQuantity(index);
                    },
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
            Text('${item['price'] ?? 0}원', style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text('${(item['price'] ?? 0) * (item['quantity'] ?? 1)}원', style: TextStyle(fontSize: 16, color: Colors.black)),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalPriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('총 ${calculateTotalSelectedItems()}개  ', style: TextStyle(fontSize: 16)),
        Text('${calculateTotalSelectedPrice()}원', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                product: {'product_id': 1, 'name': '커피', 'price': 5000, 'image': 'image_url'},  // 예시 데이터
                storeId: '1',
                orderOption: widget.orderoption,
                quantity: 1,
                selectedCup: 'Solo',
                tk: '1',
                keypoint: 1,
                orderprice: 0,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF5B1333),
        ),
        child: Text('${calculateTotalSelectedPrice()}원 주문하기', style: TextStyle(fontSize: 18,color: Colors.white)),
      ),
    );
  }

  void deleteSelectedItems() {
    setState(() {
      cartItems.removeWhere((item) => isSelectedList[cartItems.indexOf(item)]);
      isSelectedList.removeWhere((isSelected) => isSelected);
    });
  }
}

void main() => runApp(MaterialApp(
  home: ShoppingCartScreen(orderoption: '매장 이용',),
));
