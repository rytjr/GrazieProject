import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertest/PaymentScreen.dart';
import 'package:fluttertest/ShoppingCartScreen.dart';
import 'package:fluttertest/HomeScrean.dart';
import 'dart:convert';
import 'package:intl/intl.dart'; // 날짜 형식을 맞추기 위해 추가

class ProductOrderScreen extends StatefulWidget {
  final dynamic product;
  final String storeId;  // 매장 ID 추가
  final String orderOption;  // 매장이용 or To-Go 추가

  // 생성자에서 product, storeId, orderOption을 받도록 수정
  ProductOrderScreen({
    required this.product,
    required this.storeId,  // 매장 ID 받기
    required this.orderOption,  // 매장이용 or To-Go 받기
  });


  @override
  _ProductOrderScreenState createState() => _ProductOrderScreenState();
}

class _ProductOrderScreenState extends State<ProductOrderScreen> {
  int quantity = 1;
  String selectedCup = "Solo"; // 기본 선택된 컵 옵션
  String orderMode = "매장"; // 기본 주문 형태 (매장 or 테이크아웃)
  int storeId = 1; // 매장 ID (예시)
  int userId = 2; // 사용자 ID (예시)
  int? couponId; // 사용한 쿠폰 ID (nullable)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product['name'],
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "컵 선택",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                _buildCupOption("Solo", "22ml"),
                SizedBox(width: 10),
                _buildCupOption("Doppio", "44ml"),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(10),
              color: Colors.green[100],
              child: Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (bool? value) {},
                  ),
                  Expanded(
                    child: Text(
                      "환경을 위해 친환경 캠페인에 동참해 보세요.\n개인컵 사용하기",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text(
                "퍼스널 옵션",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // 퍼스널 옵션 선택 화면으로 이동
              },
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (quantity > 1) {
                          setState(() {
                            quantity--;
                          });
                        }
                      },
                      icon: Icon(Icons.remove),
                    ),
                    Text(
                      quantity.toString(),
                      style: TextStyle(fontSize: 18),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                      icon: Icon(Icons.add),
                    ),
                  ],
                ),
                Text(
                  "${widget.product['price'] * quantity}원",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // 담기 버튼 눌렸을 때 모달 창 표시
                      _showModalBottomSheet(context);
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "담기",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // 주문하기 버튼 눌렸을 때 PaymentScreen으로 데이터 전달
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                            product: widget.product,
                            storeId: widget.storeId,
                            orderOption: widget.orderOption,
                            quantity: quantity,
                            selectedCup: selectedCup,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "주문하기",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCupOption(String title, String subtitle) {
    bool isSelected = selectedCup == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCup = title;
          });
        },
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.brown : Colors.white,
            border: Border.all(color: isSelected ? Colors.brown : Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 모달 창 표시하는 함수
  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '장바구니에 추가되었습니다.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // 장바구니로 이동하는 로직 추가
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShoppingCartScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.brown),
                      padding: EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    child: Text('장바구니 가기'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              OrderContent(
                                storeId: int.parse(widget.storeId),
                                // 매장 ID를 int로 변환하여 전달
                                orderMode: widget
                                    .orderOption, // 매장이용 or To-Go 정보 전달
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      padding: EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    child: Text(
                      '다른 메뉴 더보기',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}