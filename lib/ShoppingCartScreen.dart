import 'package:flutter/material.dart';

class ShoppingCartScreen extends StatelessWidget {
  // Sample data
  final List<dynamic> cartItems = [
    {
      "name": "아이스 플랫 화이트",
      "description": "ICED/일회용컵",
      "price": 5600,
      "quantity": 2,
      "image": "https://link.to/your/image.jpg"
    },
    {
      "name": "아이스 플랫 화이트",
      "description": "ICED/일회용컵",
      "price": 5600,
      "quantity": 1,
      "image": "https://link.to/your/image.jpg"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('장바구니', style: TextStyle(color: Colors.white)),
            Text('다산 그라찌에 (매장 이용)', style: TextStyle(fontSize: 14, color: Colors.grey[300])),
          ],
        ),
        backgroundColor: Color(0xFF5B1333),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: Image.network(item['image'], width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(item['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['description']),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                // Decrease quantity code here
                              },
                            ),
                            Text(item['quantity'].toString()),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                // Increase quantity code here
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Text('${item['price'] * item['quantity']}원'),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('총 ${cartItems.length}개', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Order now code here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF5B1333),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text('주문하기', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: ShoppingCartScreen(),
));
