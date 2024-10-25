import 'package:flutter/material.dart';
import 'package:fluttertest/SecureStorageService.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class OrderListScreen extends StatefulWidget {
  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  String selectedPeriod = "1개월";
  List<dynamic> orderList = []; // 주문 내역 리스트
  String searchQuery = ""; // 검색어
  String name = '';


  Future<void> fetchGetName() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    print("제발2 $token");

    final response = await http.get(
      Uri.parse('http://34.64.110.210:8080/users/readProfile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decodedResponseBody = utf8.decode(response.bodyBytes);
      print('order' + decodedResponseBody);

      setState(() {
        final Map<String, dynamic> data = jsonDecode(decodedResponseBody);
        name = data['name']; // 사용자 이름 설정
      });

      print("이름 ㅎㅎ : $name");
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
    await fetchGetName(); // 사용자 이름 불러오기
    await Future.delayed(Duration(seconds: 1)); // 1초 대기
    fetchOrderList(); // 주문 내역 불러오기
  }

  void fetchOrderList() async {
    // 주문 내역을 불러오는 로직 (API 호출)
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();

    // API 경로를 확인하세요. `$name`이 올바르게 설정되었는지 확인
    final response = await http.get(
      Uri.parse('http://34.64.110.210:8080/api/pay/get/list/$name'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decodedResponseBody = utf8.decode(response.bodyBytes);
      print('주문내역 : $decodedResponseBody');

      setState(() {
        orderList = jsonDecode(decodedResponseBody);
      });
    } else {
      throw Exception('Failed to load orders');
    }
  }
  void filterByDate(String period) {
    setState(() {
      selectedPeriod = period;
      // 기간에 따라 필터링하는 로직 추가
    });
  }

  void searchOrders(String query) {
    setState(() {
      searchQuery = query;
      // 검색어에 따라 필터링하는 로직 추가
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('주문 내역'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FilterButton('1주일', filterByDate),
                FilterButton('1개월', filterByDate),
                FilterButton('3개월', filterByDate),
                FilterButton('기간설정', filterByDate),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                labelText: '검색',
                border: OutlineInputBorder(),
              ),
              onChanged: searchOrders,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: orderList.length,
                itemBuilder: (context, index) {
                  final order = orderList[index];
                  return OrderTile(order);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget FilterButton(String label, Function(String) onTap) {
    return OutlinedButton(
      onPressed: () => onTap(label),
      child: Text(label),
    );
  }

  Widget OrderTile(dynamic order) {
    return ListTile(
      leading: Image.network(order['image']),
      title: Text(order['name']),
      subtitle: Text('${order['price']}원\n${order['date']}'),
      isThreeLine: true,
    );
  }
}
