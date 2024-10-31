import 'package:flutter/material.dart';
import 'package:fluttertest/SecureStorageService.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertest/PaymentScreen.dart';
import 'package:fluttertest/HomeScrean.dart';
import 'package:fluttertest/ShoppingCartScreen.dart';
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
  List<dynamic> cartItems = []; // 장바구니 항목 저장 변수
  bool isLoading = true;

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

  // 장바구니 리스트를 가져오는 함수
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

    if (response.statusCode == 200) {
      setState(() {
        cartItems = jsonDecode(utf8.decode(response.bodyBytes));
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load cart items');
    }
  }

  // 주문하기 버튼 클릭 시 장바구니 체크 후 모달 표시 함수
  Future<void> handleOrder() async {
    await fetchCartItems();

    if (cartItems.isNotEmpty) {
      _showCartExistsModal();
    } else {
      // 장바구니에 기존 항목이 없으면 바로 결제 화면으로 이동
      _navigateToPaymentScreen();
    }
  }

  // 장바구니에 항목이 존재할 때 표시할 모달
  void _showCartExistsModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('알림'),
          content: Text('장바구니에 담은 메뉴가 존재합니다. 그냥 결제 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ShoppingCartScreen(
                      orderoption: widget.orderOption,
                      storeId: widget.storeId,
                    ),
                  ),
                );
              },
              child: Text('장바구니 가기',style: TextStyle(fontSize: 14, color: Color(0xFF5B1333))),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToPaymentScreen();
              },
              child: Text('결제하기',style: TextStyle(fontSize: 14, color: Color(0xFF5B1333))),
            ),
          ],
        );
      },
    );
  }

  void _navigateToPaymentScreen() {
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
          onename: widget.product['name'],
        ),
      ),
    );
  }

  Future<void> _addToCart() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    final url = Uri.parse('http://34.64.110.210:8080/cart/add');

    // 서버로 보낼 데이터 생성
    final body = {
      "productId": widget.product['productId'].toString(),
      "size": selectedSize.toLowerCase(),
      "temperature": widget.selectedTemperature.toLowerCase(),
      "quantity": quantity,
      "personalOptions": {
        "concentration": "LIGHT",
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

      if (response.statusCode == 200) {
        _showAddToCartModal();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('장바구니 추가 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('장바구니 추가 중 오류 발생')),
      );
    }
  }

  // 장바구니 추가 확인 모달 창
  void _showAddToCartModal() {
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShoppingCartScreen(
                            orderoption: widget.orderOption,
                            storeId: widget.storeId,
                          ),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Color(0xFF5B1333)),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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

  // 요구사항을 저장하는 상태 변수
  String specialRequest = "";

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

  int _calculateAdditionalPrice() {
    int additionalPrice = 0;

    additionalPrice += shotAddition * 500;
    additionalPrice += pearlAddition * 700;
    additionalPrice += syrupAddition * 200;
    additionalPrice += sugarAddition * 200;
    additionalPrice += whippedCreamAddition * 700;

    if (selectedTumbler == "USE") {
      additionalPrice -= 300;
    }

    return additionalPrice;
  }

  int _getTotalPrice() {
    int basePrice = _getBasePrice() + _calculateAdditionalPrice();
    int totalPrice = basePrice * quantity;

    if (widget.selectedTemperature == 'ICE') {
      totalPrice += 300 * quantity;
    }

    return totalPrice;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(widget.product['name']),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                      hintText: "예: 얼음은 적게, 시럽 추가",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF5B1333), width: 1.5),
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
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0, left: 16, right: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                          onPressed: _addToCart,
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
                          onPressed: handleOrder,
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
        ],
      ),
    );
  }


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
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
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
                    _buildOptionSection("샷 추가", shotAddition, (value) {
                      setModalState(() {
                        shotAddition = value;
                      });
                      setState(() {});
                    }),
                    _buildOptionSection("펄 추가", pearlAddition, (value) {
                      setModalState(() {
                        pearlAddition = value;
                      });
                      setState(() {});
                    }),
                    _buildOptionSection("설탕 추가", sugarAddition, (value) {
                      setModalState(() {
                        sugarAddition = value;
                      });
                      setState(() {});
                    }),
                    _buildOptionSection("휘핑크림 추가", whippedCreamAddition, (value) {
                      setModalState(() {
                        whippedCreamAddition = value;
                      });
                      setState(() {});
                    }),
                    _buildHorizontalRadioOption("얼음", selectedIce, ["NONE", "LESS", "NORMAL", "MORE"], (value) {
                      setModalState(() {
                        selectedIce = value!;
                      });
                      setState(() {});
                    }),
                    _buildHorizontalRadioOption("텀블러 사용 여부", selectedTumbler, ["USE", "NOT_USE"], (value) {
                      setModalState(() {
                        selectedTumbler = value!;
                      });
                      setState(() {});
                    }),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
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
}
