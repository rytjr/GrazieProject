// lib/screens/first_screen.dart
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:fluttertest/MenuItem.dart';

class Passenger extends StatefulWidget {
  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<Passenger> {
  final Dio _dio = Dio();
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
  }

  void _fetchMenuItems() async {
    try {
      final response = await _dio.get('https://your-server-api.com/menu');  // 서버 주소와 엔드포인트 수정
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        setState(() {
          _menuItems = data.map((item) => MenuItem.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load menu';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load menu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // 검색 기능 추가 가능
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Text(
          _errorMessage,
          style: TextStyle(color: Colors.red, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      )
          : ListView.builder(
        itemCount: _menuItems.length,
        itemBuilder: (context, index) {
          final menuItem = _menuItems[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                'https://your-server-api.com/${menuItem.image}',  // 이미지 URL 수정
              ),
              radius: 30,
            ),
            title: Text(menuItem.name, style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${menuItem.price}원'),
            onTap: () {
              // 메뉴 상세 페이지로 이동 가능
            },
          );
        },
      ),
    );
  }
}