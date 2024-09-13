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


/*import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems = [
    {
      'name': '아이스 플랫 화이트',
      'description': 'ICED/일회용컵',
      'price': 5600,
      'quantity': 2,
      'image': 'assets/images/iced_flat_white.png',
    },
    {
      'name': '아이스 플랫 화이트',
      'description': 'ICED/일회용컵',
      'price': 5600,
      'quantity': 1,
      'image': 'assets/images/iced_flat_white.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('장바구니'),
        centerTitle: true,
      ),
      body: Padding(
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
                  return _buildCartItem(cartItems[index]);
                },
                separatorBuilder: (context, index) => Divider(thickness: 1, color: Colors.grey[300]), // 리스트 사이 얇은 경계선
              ),
            ),
            SizedBox(height: 20),
            _buildTotalPriceRow(),
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
            Checkbox(value: false, onChanged: (bool? value) {}),
            Text('전체 선택'),
          ],
        ),
        Text('선택 삭제', style: TextStyle(color: Colors.red)),
      ],
    );
  }

  // 각 메뉴 아이템을 표시하는 위젯
  Widget _buildCartItem(Map<String, dynamic> item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(value: false, onChanged: (bool? value) {}),
        SizedBox(width: 10),
        Image.asset(item['image'], width: 50, height: 50, fit: BoxFit.cover),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(item['description'], style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text('옵션변경', style: TextStyle(fontSize: 14, color: Colors.red)),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.remove_circle_outline, size: 20),
                  ),
                  Text('${item['quantity']}', style: TextStyle(fontSize: 16)),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.add_circle_outline, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
        Text('${item['price'] * item['quantity']}원', style: TextStyle(fontSize: 16)),
      ],
    );
  }

  // 총 금액을 표시하는 위젯
  Widget _buildTotalPriceRow() {
    int total = cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('총 ${cartItems.length}개  ', style: TextStyle(fontSize: 16)),
        Text('$total원', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
          primary: Color(0xFF880E4F), // 와인색 버튼
        ),
        child: Text('주문하기', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: CartScreen(),
));
*/