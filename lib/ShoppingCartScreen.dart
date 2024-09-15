import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShoppingCartScreen extends StatefulWidget {
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
    final response = await http.get(Uri.parse('http://10.0.2.2:8000/cart/items?userId=2'));

    if (response.statusCode == 200) {
      setState(() {
        cartItems = json.decode(response.body);
        isSelectedList = List<bool>.filled(cartItems.length, false); // 체크박스 리스트 초기화
        isLoading = false;
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
      appBar: AppBar(
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
              '다산 그라찌에 (매장 이용)',
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
          child: Text('선택 삭제', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  // 각 메뉴 아이템을 표시하는 위젯
  Widget _buildCartItem(Map<String, dynamic> item, int index) {
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
        Image.network(item['image'], width: 50, height: 50, fit: BoxFit.cover),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['name'] ?? '상품 이름 없음', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Text('${item['size'] ?? ''} / ${item['cup'] ?? ''}', style: TextStyle(fontSize: 14, color: Colors.grey)),
                  SizedBox(width: 10),
                ],
              ),
              Text('옵션변경', style: TextStyle(fontSize: 14, color: Colors.red)),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      decreaseQuantity(index); // 수량 감소
                    },
                    icon: Icon(Icons.remove_circle_outline, size: 20),
                  ),
                  Text('${item['quantity']}', style: TextStyle(fontSize: 16)),
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
            Text('${item['price']}원', style: TextStyle(fontSize: 14, color: Colors.grey)), // 개별 가격
            Text('${(item['price'] * item['quantity'])}원', style: TextStyle(fontSize: 16, color: Colors.black)), // 오른쪽 하단에 총 가격 표시
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
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF880E4F), // 와인색 버튼
        ),
        child: Text('${calculateTotalSelectedPrice()}원 주문하기', style: TextStyle(fontSize: 18)),
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
  home: ShoppingCartScreen(),
));
