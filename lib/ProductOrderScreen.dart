import 'package:flutter/material.dart';
import 'package:fluttertest/SecureStorageService.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertest/PaymentScreen.dart';
import 'package:fluttertest/ShoppingCartScreen.dart';
import 'package:fluttertest/HomeScrean.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // 토큰 저장/가져오기 위한 패키지
import 'package:intl/intl.dart'; // 날짜 형식을 맞추기 위해 추가

class ProductOrderScreen extends StatefulWidget {
  final dynamic product;
  final String storeId; // 매장 ID 추가
  final String orderOption; // 매장이용 or To-Go 추가
  final String selectedTemperature; // 선택한 온도 추가
  final String tk;

  ProductOrderScreen({
    required this.product,
    required this.storeId,
    required this.orderOption,
    required this.selectedTemperature,
    required this.tk,
  });

  @override
  _ProductOrderScreenState createState() => _ProductOrderScreenState();
}

class _ProductOrderScreenState extends State<ProductOrderScreen> {
  int quantity = 1;
  String selectedSize = "Small"; // 기본 선택된 사이즈 옵션
  int storeId = 1;
  int userId = 2;
  int? couponId;
  int orderprice = 0;
  final _storage = FlutterSecureStorage(); // SecureStorage 초기화

  // 퍼스널 옵션 기본값 설정
  String selectedIce = "NORMAL"; // 얼음 옵션
  String selectedTumbler = "NOT_USE"; // 텀블러 사용 여부

  int shotAddition = 0; // 샷 추가 기본값
  int pearlAddition = 0; // 펄 추가 기본값
  int syrupAddition = 0; // 시럽 추가 기본값
  int sugarAddition = 0; // 설탕 추가 기본값
  int whippedCreamAddition = 0; // 휘핑크림 추가 기본값
  int keypoint = 0;

  Future<void> _addToCart() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    print('toekb');
    final url = Uri.parse('http://34.64.110.210:8080/cart/add');

    // 서버로 보낼 데이터 생성
    final body = {
      "productId": widget.product['productId'].toString(), // product ID
      "size": selectedSize.toLowerCase(), // small, medium, large 등을 소문자로 전송
      "temperature": widget.selectedTemperature.toLowerCase(), // ice, hot
      "quantity": quantity,
      "personalOptions": {
        "concentration": "LIGHT", // 농도는 기본값
        "shotAddition": shotAddition,
        "personalTumbler": selectedTumbler,
        "pearlAddition": pearlAddition,
        "syrupAddition": syrupAddition,
        "sugarAddition": sugarAddition,
        "whippedCreamAddition": whippedCreamAddition,
        "iceAddition": selectedIce
      }
    };

    try {
      // POST 요청 보내기
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(body),
      );
      print('haha ${response.statusCode}');
      print(token);
      // 서버 응답 확인
      if (response.statusCode == 200) {
        // 성공적으로 추가된 경우
        print('Cart item added successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('장바구니에 추가되었습니다.')),
        );
      } else {
        // 서버 에러 응답 처리
        print('Failed to add item to cart: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('장바구니 추가 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // 네트워크 에러 처리
      print('Error occurred while adding to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('장바구니 추가 중 오류 발생')),
      );
    }
  }

  // 요구사항을 저장하는 상태 변수
  String specialRequest = "";

  // 각 사이즈에 따른 가격을 계산
  int _getBasePrice() {
    switch (selectedSize) {
      case "Small":
        return widget.product['smallPrice'];
      case "Medium":
        return widget.product['mediumPrice'];
      case "Large":
        return widget.product['largePrice'];
      default:
        return widget.product['smallPrice'];
    }
  }

  // 추가 가격 계산 (샷, 펄, 시럽, 설탕 추가 및 텀블러 사용에 따른 할인 적용)
  int _calculateAdditionalPrice() {
    int additionalPrice = 0;

    additionalPrice += shotAddition * 500; // 샷당 500원 추가
    additionalPrice += pearlAddition * 700; // 펄 추가시 700원 추가
    additionalPrice += syrupAddition * 200; // 시럽 추가시 200원 추가
    additionalPrice += sugarAddition * 200; // 설탕 추가시 200원 추가
    additionalPrice += whippedCreamAddition * 700; // 휘핑크림 추가시 700원 추가

    if (selectedTumbler == "USE") {
      additionalPrice -= 300; // 텀블러 사용시 300원 할인
    }

    return additionalPrice;
  }

// 총 가격 계산 (기본 가격 + 추가 가격 + ICE 옵션에 따른 추가 금액, 수량 반영)
  int _getTotalPrice() {
    int basePrice = _getBasePrice() + _calculateAdditionalPrice(); // 기본 가격에 추가 가격을 더함
    int totalPrice = basePrice * quantity; // 수량을 곱하여 총 가격 계산

    // ICE 선택 시 300원 추가
    if (widget.selectedTemperature == 'ICE') {
      totalPrice += 300 * quantity; // 수량만큼 ICE 추가 비용을 곱함
    }

    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드 올라와도 버튼 고정
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.product['name']),
      ),
      body: SingleChildScrollView( // 스크롤 가능하도록 변경
        child: Padding(
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
                "사이즈 선택",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5B1333),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  _buildSizeOption("Small", widget.product['smallPrice']),
                  SizedBox(width: 10),
                  _buildSizeOption("Medium", widget.product['mediumPrice']),
                  SizedBox(width: 10),
                  _buildSizeOption("Large", widget.product['largePrice']),
                ],
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
                  _showPersonalOptionModal(context);
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: "추가 요구사항을 적어주세요",
                  labelStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  hintText: "예: 얼음은 적게, 시럽 추가",
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[100], // 배경색 추가
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12), // 더 둥근 테두리
                    borderSide: BorderSide.none, // 테두리 제거
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF5B1333), width: 1.5), // 포커스 시 테두리 색상
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                maxLines: 2,
                onChanged: (value) {
                  setState(() {
                    specialRequest = value;
                  });
                },
              ),
              SizedBox(height: 110),
              SizedBox(height: 30),
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
                    "${_getTotalPrice()}원",
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
                        _addToCart();
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
                        keypoint = 0;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                              product: widget.product,
                              storeId: widget.storeId,
                              orderOption: widget.orderOption,
                              quantity: quantity,
                              selectedCup: selectedSize,
                              specialRequest: specialRequest,
                              tk: widget.tk,
                              keypoint: keypoint,
                              orderprice: _getTotalPrice(),
                              onename : widget.product['name'],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF5B1333),
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
      ),
    );
  }

  // 사이즈 옵션 위젯 빌드
  Widget _buildSizeOption(String title, int price) {
    bool isSelected = selectedSize == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedSize = title;
          });
        },
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF5B1333) : Colors.white,
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
                "${price}원",
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

  // 퍼스널 옵션 모달 창
  void _showPersonalOptionModal(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 뒤로가기 버튼
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context); // 모달 닫기
                        },
                      ),
                    ),
                    Text(
                      "퍼스널 옵션",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildOptionSection(
                      "샷 추가",
                      shotAddition,
                          (value) {
                        setModalState(() {
                          shotAddition = value;
                        });
                        setState(() {}); // 업데이트 후 가격 반영
                      },
                    ),
                    _buildOptionSection(
                      "펄 추가",
                      pearlAddition,
                          (value) {
                        setModalState(() {
                          pearlAddition = value;
                        });
                        setState(() {}); // 업데이트 후 가격 반영
                      },
                    ),
                    _buildOptionSection(
                      "설탕 추가",
                      sugarAddition,
                          (value) {
                        setModalState(() {
                          sugarAddition = value;
                        });
                        setState(() {}); // 업데이트 후 가격 반영
                      },
                    ),
                    _buildOptionSection(
                      "휘핑크림 추가",
                      whippedCreamAddition,
                          (value) {
                        setModalState(() {
                          whippedCreamAddition = value;
                        });
                        setState(() {}); // 업데이트 후 가격 반영
                      },
                    ),
                    _buildHorizontalRadioOption(
                      "얼음",
                      selectedIce,
                      ["NONE", "LESS", "NORMAL", "MORE"],
                          (value) {
                        setModalState(() {
                          selectedIce = value!;
                        });
                        setState(() {});
                      },
                    ),
                    _buildHorizontalRadioOption(
                      "텀블러 사용 여부",
                      selectedTumbler,
                      ["USE", "NOT_USE"],
                          (value) {
                        setModalState(() {
                          selectedTumbler = value!;
                        });
                        setState(() {}); // 업데이트 후 가격 반영
                      },
                    ),

                    SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // 모달 닫기
                      },
                      child: Text("확인", style: TextStyle(fontSize: 18, color: Color(0xFF5B1333))),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOptionSection(String title, int count, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                if (count > 0) {
                  onChanged(count - 1);
                }
              },
              icon: Icon(Icons.remove),
            ),
            Text(
              count.toString(),
              style: TextStyle(fontSize: 18),
            ),
            IconButton(
              onPressed: () {
                onChanged(count + 1);
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }

  // 가로로 배치된 라디오 버튼 그룹 (얼음 옵션 및 텀블러 사용 여부)
  Widget _buildHorizontalRadioOption(String title, String selectedValue, List<String> options, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: options.map((String option) {
            return Row(
              children: [
                Radio<String>(
                  value: option,
                  groupValue: selectedValue,
                  onChanged: onChanged,
                ),
                Text(option),
              ],
            );
          }).toList(),
        ),
      ],
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
                            builder: (context) => ShoppingCartScreen(orderoption : widget.orderOption,storeId: widget.storeId,)),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF5B1333)),
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
                                orderMode: widget.orderOption,
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF5B1333),
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
