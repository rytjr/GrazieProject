import 'package:flutter/material.dart';
import 'package:fluttertest/ProductOrderScreen.dart';

class ProductDetailScreen extends StatelessWidget {
  final dynamic product;

  ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['name']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                product['image'],
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 30, 22, 0),
                child: Text(
                  product['name'],
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 30, 22, 0),
                child: Text(
                  product['explanation'],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 30, 22, 0),
                child: Text(
                  '${product['price']}원',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 13, 22, 0),
                child: Row(
                  children: _buildTemperatureButtons(product['temperature']),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
                child: Container(
                  height: 103,
                  color: Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      "퍼스널 옵션을 선택하여 디카프레인 블론드로 즐겨보세요.\n"
                          "우유 거품 없이를 원할 경우, 에스프레소를 주문해 주세요.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 5),
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductOrderScreen(product: product),
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

  List<Widget> _buildTemperatureButtons(String temperature) {
    List<Widget> buttons = [];

    if (temperature == 'ice') {
      buttons.add(
        SizedBox(
          height: 32,
          child: OutlinedButton(
            onPressed: () {
              // ICE 버튼이 눌렸을 때의 동작
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.brown),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text(
              "ICE ONLY",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
          ),
        ),
      );
    }

    if (temperature == 'hot') {
      buttons.add(
        SizedBox(
          width: double.infinity,
          height: 32,
          child: OutlinedButton(
            onPressed: () {
              // HOT 버튼이 눌렸을 때의 동작
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.brown),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Text(
              "HOT ONLY",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
          ),
        ),
      );
    }

    if (temperature == 'both') {
      buttons.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 22.0, right: 5.0),
            child: SizedBox(
              width: double.infinity,
              height: 32,
              child: OutlinedButton(
                onPressed: () {
                  // ICE 버튼이 눌렸을 때의 동작
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.brown),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  "ICE",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      buttons.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 5.0, right: 22.0),
            child: SizedBox(
              width: double.infinity,
              height: 32,
              child: OutlinedButton(
                onPressed: () {
                  // HOT 버튼이 눌렸을 때의 동작
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.brown),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  "HOT",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
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