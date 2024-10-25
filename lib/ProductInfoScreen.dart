import 'package:flutter/material.dart';

class ProductInfoScreen extends StatelessWidget {
  final dynamic product;

  ProductInfoScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("제품 영양 정보"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${product['size']}ml", // 용량 정보
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            _buildNutritionRow("칼로리", "${product['information']['calories']}kcal"),
            Divider(color: Colors.grey), // 회색 선 추가
            _buildNutritionRow("포화지방", "${product['information']['saturatedFat']}g"),
            Divider(color: Colors.grey), // 회색 선 추가
            _buildNutritionRow("단백질", "${product['information']['protein']}g"),
            Divider(color: Colors.grey), // 회색 선 추가
            _buildNutritionRow("나트륨", "${product['information']['sodium']}mg"),
            Divider(color: Colors.grey), // 회색 선 추가
            _buildNutritionRow("당류", "${product['information']['sugar']}g"),
            Divider(color: Colors.grey), // 회색 선 추가
            _buildNutritionRow("카페인", "${product['information']['caffeine']}mg"),
            Divider(color: Colors.grey), // 회색 선 추가
            // Spacer(),
            // Text(
            //   "고카페인 함유 | 해당 제품은 고카페인 음료입니다.\n어린이, 임산부, 카페인 민감자는 섭취에 주의해 주세요.",
            //   style: TextStyle(color: Colors.grey),
            //   textAlign: TextAlign.center,
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRow(String nutrient, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nutrient, style: TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
