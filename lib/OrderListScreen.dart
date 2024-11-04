import 'package:flutter/material.dart';
import 'package:fluttertest/SecureStorageService.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class OrderListScreen extends StatefulWidget {
  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  String selectedPeriod = "1개월";
  List<dynamic> orderList = [];
  List<dynamic> filteredOrderList = [];
  String searchQuery = "";
  String name = '';

  Future<void> fetchGetName() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();

    final response = await http.get(
      Uri.parse('http://34.64.110.210:8080/users/readProfile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decodedResponseBody = utf8.decode(response.bodyBytes);

      setState(() {
        final Map<String, dynamic> data = jsonDecode(decodedResponseBody);
        name = data['name'];
      });
    } else {
      throw Exception('Failed to load profile');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchGetName();
    await Future.delayed(Duration(seconds: 1));
    await fetchOrderList();
    applyFilters();
  }

  Future<void> fetchOrderList() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();

    final response = await http.get(
      Uri.parse('http://34.64.110.210:8080/api/order/get/user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print("주문내역 : ${jsonDecode(utf8.decode(response.bodyBytes))}");
    print(response.request);
    if (response.statusCode == 200) {
      setState(() {
        orderList = jsonDecode(utf8.decode(response.bodyBytes));
        filteredOrderList = orderList;
      });
    } else {
      throw Exception('Failed to load orders');
    }
  }

  void filterByDate(String period) {
    setState(() {
      selectedPeriod = period;
    });
    applyFilters();
  }

  void searchOrders(String query) {
    setState(() {
      searchQuery = query;
    });
    applyFilters();
  }

  void applyFilters() {
    DateTime now = DateTime.now();
    DateTime? startDate;

    switch (selectedPeriod) {
      case '1주일':
        startDate = now.subtract(Duration(days: 7));
        break;
      case '1개월':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case '3개월':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      default:
        startDate = null;
        break;
    }

    setState(() {
      filteredOrderList = orderList.where((order) {
        final orderDate = DateTime.parse(order['orderGetDTO']['order_date']);
        bool matchesDate = startDate == null || orderDate.isAfter(startDate);
        bool matchesSearch = searchQuery.isEmpty ||
            order['orderItemsGetDTOs'][0]['product']['name']
                .contains(searchQuery);
        return matchesDate && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('주문 내역', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 1.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FilterButton('1주일', filterByDate, selectedPeriod == '1주일'),
                  FilterButton('1개월', filterByDate, selectedPeriod == '1개월'),
                  FilterButton('3개월', filterByDate, selectedPeriod == '3개월'),
                ],
              ),
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: '검색',
                labelStyle: TextStyle(color: Colors.grey[700]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: searchOrders,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredOrderList.length,
                itemBuilder: (context, index) {
                  final order = filteredOrderList[index];
                  return OrderTile(order);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget FilterButton(String label, Function(String) onTap, bool isSelected) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => onTap(label),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey,
            width: 1.5,
          ),
          backgroundColor: isSelected ? Colors.blue[50] : Colors.white,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget OrderTile(dynamic order) {
    final orderDTO = order['orderGetDTO'];
    final orderItems = order['orderItemsGetDTOs'];

    if (orderItems == null || orderItems.isEmpty) {
      return ListTile(
        title: Text('주문 항목이 없습니다'),
      );
    }

    final orderDate = DateTime.parse(orderDTO['order_date']);
    final formattedDate = DateFormat('yyyy-MM-dd').format(orderDate);

    return ExpansionTile(
      title: Text('주문 날짜: $formattedDate'),
      subtitle: Text('총 금액: ${orderDTO['final_price']}원'),
      children: orderItems.map<Widget>((item) {
        final product = item['product'];
        return ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: product != null
                ? NetworkImage('http://34.64.110.210:8080/' + product['image'])
                : null,
            onBackgroundImageError: (error, stackTrace) {
              print(error);
            },
            child: product == null ? Icon(Icons.image_not_supported) : null,
          ),
          title: Text(product != null ? product['name'] : '제품 이름 없음'),
          subtitle: Text(
            '가격: ${item['product_price']}원\n수량: ${item['quantity']}개',
          ),
        );
      }).toList(),
    );
  }
}
