import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  final dynamic product;

  ProductDetailScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ${product['price']}'),
            SizedBox(height: 10),
            Text('Description: ${product['explanation']}'),
            // 추가적인 정보를 여기에 추가
          ],
        ),
      ),
    );
  }
}
