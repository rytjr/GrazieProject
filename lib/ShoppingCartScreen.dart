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

  // 서버로부터 데이터를 받아오는 함수
  Future<void> fetchCartItems() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    print('카트코튼 $token');
    final response = await http.get(Uri.parse('http://34.64.110.210:8080/cart/items'),
      headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
      },
    );

    final decodedResponseBody = utf8.decode(response.bodyBytes);
    print('쿠폰이당 $decodedResponseBody');
    if (response.statusCode == 200) {
      setState(() {
        cartItems = jsonDecode(decodedResponseBody);
        isSelectedList = List<bool>.filled(cartItems.length, false); // 체크박스 리스트 초기화
        isLoading = false;
        print('카트 결과 $cartItems');
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load cart items');
    }
  }

  // 체크된 항목들의 총 가격 계산
  int calculateTotalSelectedPrice() {
    int total = 0;
    for (int i = 0; i < cartItems.length; i++) {
      if (isSelectedList[i]) {
        total += (cartItems[i]['price'] as int) * (cartItems[i]['quantity'] as int);
      }
    }
    return total;
  }

  // 체크된 항목들의 총 개수 계산
  int calculateTotalSelectedItems() {
    int total = 0;
    for (int i = 0; i < isSelectedList.length; i++) {
      if (isSelectedList[i]) {
        total++;
      }
    }
    return total;
  }

  // 수량 증가 로직
  void increaseQuantity(int index) {
    setState(() {
      cartItems[index]['quantity']++;
    });
  }

  // 수량 감소 로직
  void decreaseQuantity(int index) {
    setState(() {
      if (cartItems[index]['quantity'] > 1) {
        cartItems[index]['quantity']--;
      }
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
          ? Center(child: CircularProgressIndicator()) // 로딩 중일 때
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
            Divider(thickness: 2, color: Colors.grey[300]), // 상단 굵은 회색선
            _buildHeaderRow(),
            Divider(thickness: 1, color: Colors.grey[300]), // 메뉴 목록 위 얇은 경계선
            Expanded(
              child: ListView.separated(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  return _buildCartItem(cartItems[index], index);
                },
                separatorBuilder: (context, index) => Divider(thickness: 1, color: Colors.grey[300]), // 리스트 사이 얇은 경계선
              ),
            ),
            SizedBox(height: 20),
            _buildTotalPriceRow(), // 총 가격을 맨 밑에 위치
            SizedBox(height: 20),
            _buildOrderButton(),
          ],
        ),
      ),
    );
  }

  // 상단 메뉴 선택/삭제 옵션
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
                  isSelectedList = List<bool>.filled(cartItems.length, value ?? false); // 전체 선택/해제
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

  // 각 메뉴 아이템을 표시하는 위젯
  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    print('Product name: ${item['name']}');
    print('Product image: ${item['image']}');
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
        // null 체크: 이미지 URL이 없을 경우 기본 이미지 사용
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
              // null 체크: 상품 이름이 null일 경우 기본 값 제공
              Text(item['productName'] ?? '상품 이름 없음', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  // null 체크: size와 cup 필드가 null일 경우 빈 문자열 처리
                  Text('${item['size'] ?? ''} / ${item['cup'] ?? ''}', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  SizedBox(width: 10),
                ],
              ),
              Text('옵션변경', style: TextStyle(fontSize: 14, color: Colors.black)),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      decreaseQuantity(index); // 수량 감소
                    },
                    icon: Icon(Icons.remove_circle_outline, size: 20),
                  ),
                  // null 체크: 수량이 null일 경우 기본값 1 사용
                  Text('${item['quantity'] ?? 1}', style: TextStyle(fontSize: 16)),
                  IconButton(
                    onPressed: () {
                      increaseQuantity(index); // 수량 증가
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
            // null 체크: 가격이 null일 경우 0으로 설정
            Text('${item['price'] ?? 0}원', style: TextStyle(fontSize: 14, color: Colors.grey)), // 개별 가격
            // null 체크: 가격과 수량이 null일 경우 0으로 설정
            Text('${(item['price'] ?? 0) * (item['quantity'] ?? 1)}원', style: TextStyle(fontSize: 16, color: Colors.black)), // 총 가격 표시
          ],
        ),
      ],
    );
  }

  // 총 금액을 표시하는 위젯 (화면의 맨 밑에 위치)
  Widget _buildTotalPriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('총 ${calculateTotalSelectedItems()}개  ', style: TextStyle(fontSize: 16)),
        Text('${calculateTotalSelectedPrice()}원', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // 주문하기 버튼
  Widget _buildOrderButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // 주문하기 동작 추가
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentScreen(
                product: cartItems,
                storeId: '',
                orderOption: '매장 이용',
                quantity: 1,
                selectedCup: 'small',
                specialRequest: '',  // 요구사항 전달
                tk : '',
                keypoint : 0,
                orderprice : 0,
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

  // 선택된 항목 삭제
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
