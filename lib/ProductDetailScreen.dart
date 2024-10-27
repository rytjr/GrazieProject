import 'package:flutter/material.dart';
import 'package:fluttertest/ProductOrderScreen.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic product;
  final String storeId;  // 매장 ID 추가
  final String orderOption;  // 매장이용 or To-Go 추가
  final String tk;

  ProductDetailScreen({
    required this.product,
    required this.storeId,  // 매장 ID 받기
    required this.orderOption,  // 매장이용 or To-Go 받기
    required this.tk,
  });

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String? selectedTemperature;  // 사용자가 선택한 온도를 저장할 변수

  @override
  void initState() {
    super.initState();
    // 화면이 시작될 때 토큰 출력
    print('Token: ${widget.tk}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드 올라와도 버튼 고정
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.product['name'] ?? '상품 이름 없음'),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이미지 영역
              Image.network(
                'http://34.64.110.210:8080/' + widget.product['image'] ?? 'https://example.com/default_image.png', // 기본 이미지 URL
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error, size: 100, color: Colors.red); // 이미지 로드 실패 시
                },
              ),
              // 상품 이름
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 30, 22, 0),
                child: Text(
                  widget.product['name'] ?? '이름 없음',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 설명
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 30, 22, 0),
                child: Text(
                  widget.product['explanation'] ?? '설명 없음',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              // 가격
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 30, 22, 0),
                child: Text(
                  '${widget.product['smallPrice'] ?? 0}원',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 온도 선택 버튼 (iceAble, hotAble 기반)
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 13, 22, 0),
                child: Row(
                  children: _buildTemperatureButtons(widget.product['iceAble'] ?? false, widget.product['hotAble'] ?? false),
                ),
              ),
              // 주문하기 버튼
              SizedBox(height: 150),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 120, 22, 5),
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: selectedTemperature == null
                            ? null // 온도를 선택하지 않으면 버튼 비활성화
                            : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductOrderScreen(
                                product: widget.product,
                                storeId: widget.storeId,  // 매장 ID 전달
                                orderOption: widget.orderOption,  // 매장이용 or To-Go 전달
                                selectedTemperature: selectedTemperature!,  // 선택된 온도 전달
                                tk: widget.tk,
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
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // iceAble, hotAble에 따라 버튼 생성
  List<Widget> _buildTemperatureButtons(bool iceAble, bool hotAble) {
    List<Widget> buttons = [];

    if (iceAble) {
      buttons.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 22.0, right: 5.0),
            child: SizedBox(
              width: double.infinity,
              height: 32,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    selectedTemperature = 'ICE'; // ICE 선택
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: selectedTemperature == 'ICE' ? Colors.blue : Colors.brown), // 선택된 버튼 강조
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  "ICE",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: selectedTemperature == 'ICE' ? Colors.blue : Colors.brown, // 선택된 텍스트 강조
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (hotAble) {
      buttons.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 5.0, right: 22.0),
            child: SizedBox(
              width: double.infinity,
              height: 32,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    selectedTemperature = 'HOT'; // HOT 선택
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: selectedTemperature == 'HOT' ? Colors.blue : Colors.brown), // 선택된 버튼 강조
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  "HOT",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: selectedTemperature == 'HOT' ? Colors.blue : Colors.brown, // 선택된 텍스트 강조
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return buttons;
  }
}
