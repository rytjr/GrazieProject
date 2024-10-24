import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fluttertest/LoginScreen.dart';
import 'package:fluttertest/OrderListScreen.dart';
import 'package:fluttertest/ProductDetailScreen.dart';
import 'package:fluttertest/ShoppingCartScreen.dart';
import 'package:fluttertest/TermsOfUseScreen.dart';
import 'package:fluttertest/ApiService.dart';
import 'package:fluttertest/MyPageScreen.dart';
import 'package:fluttertest/SecureStorageService.dart';
import 'package:fluttertest/TermsScreen.dart';
import 'package:fluttertest/CouponScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<dynamic> stores = [];
  bool isLoading = true;
  String storeId = ''; // storeId 변수 추가
  String orderMode = ''; // orderMode 변수 추가
  String tokentest = '';

  @override
  void initState() {
    super.initState();
    fetchStores(); // API를 통해 매장 데이터를 불러옴
  }

  // 매장 데이터를 API로부터 가져오는 함수
  void fetchStores() async {
    try {
      var dio = Dio();
      var response = await dio.get('http://34.64.110.210:8080/api/store/get/all');
      setState(() {
        stores = response.data; // 받아온 매장 데이터를 리스트에 저장
        isLoading = false;
      });
      print(stores);
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) { // Order 탭을 클릭했을 때
      _showOrderModal(context);
    }
  }

  void _showOrderModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final double screenHeight = MediaQuery.of(context).size.height;
        return Container(
          height: screenHeight - 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '매장 선택',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator()) // 로딩 중일 때
                    : ListView.builder(
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    return _buildStoreTile(
                      stores[index]['name'],
                      stores[index]['location'],
                      // stores[index]['image'],
                      stores[index], // 매장 전체 정보
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showStoreDetailsModal(BuildContext context, String title, String address,String operatingHours, String additionalInfo, dynamic store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final double screenHeight = MediaQuery.of(context).size.height;
        return Container(
          height: screenHeight - 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        IconButton(
                          icon: Icon(Icons.more_vert),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    SizedBox(height: 20),
                    Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(address, style: TextStyle(fontSize: 18, color: Colors.grey[800])),
                    SizedBox(height: 10),
                    Text("운영 시간", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(operatingHours, style: TextStyle(fontSize: 16)),
                    SizedBox(height: 20),
                    Text("추가 정보", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(additionalInfo, style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("픽업은 어떻게 하시겠어요?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        pickupButton(context, Icons.local_cafe, "매장 이용", store),
                        pickupButton(context, Icons.shopping_bag, "To-Go", store),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }


  Widget pickupButton(BuildContext context, IconData icon, String text, dynamic store) {
    return GestureDetector(
      onTap: () {
        // storeId가 String으로 전달되었을 수 있으므로 이를 int로 변환
        int storeIdInt = int.tryParse(store['id'].toString()) ?? 0; // 변환 실패 시 0 할당

        setState(() {
          orderMode = text; // 매장 이용 또는 To-Go 저장
        });

        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderContent(
              storeId: storeIdInt, // 변환된 int형 storeId 전달
              orderMode: orderMode, // 매장이용 또는 To-Go 정보 전달
            ),
          ),
        );
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 40, color: Colors.black54),
            SizedBox(height: 4),
            Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
          ],
        ),
      ),
    );
  }



  Widget _buildStoreTile(String? title, String? subtitle,  dynamic store) {
    return GestureDetector(
      onTap: () {
        showStoreDetailsModal(
            context,
            title ?? '매장 이름 없음', // null일 때 기본값 제공
            subtitle ?? '매장 주소 없음', // null일 때 기본값 제공
            // imagePath ?? 'https://example.com/default-image.jpg', // null일 때 기본 이미지 경로 제공
            "운영 시간: 07:00 - 21:30", // 운영 시간은 임시로 설정
            "주말 15시 - 18시, DT로 전환 시간대 조정 가능합니다.", // 추가 정보 임시 설정
            store // 매장 정보를 전달
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          height: 110,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title ?? '매장 이름 없음', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(subtitle ?? '매장 주소 없음', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  List<Widget> _widgetOptions() => <Widget>[
    HomeContent(),
    OrderContent(storeId: int.tryParse(storeId) ?? 0, orderMode: orderMode), // storeId를 int로 변환
    OtherContent(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF).withOpacity(0.6), // 투명도 60%
        title: Center(
          child: Text(
            'Grazie',
            style: TextStyle(
              color: Color(0xFF5B1333),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('android/assets/images/order.png'), // 경로 수정 필요
            ),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('android/assets/images/other.png'), // 경로 수정 필요
            ),
            label: 'Other',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF5B1333),
        onTap: _onItemTapped,
      ),
      body: Stack(
        children: [
          _widgetOptions().elementAt(_selectedIndex),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<dynamic> products = [];
  bool isLoggedIn = false; // 로그인 상태를 확인하는 변수
  String userName = ''; // 사용자 이름 저장 변수'
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {

      fetchProducts();
      checkLoginStatus();  // 로그인 상태 확인 먼저 실행
    });
  }

  void fetchProducts() async {
    try {
      Response response = await apiService.getRequest('http://34.64.110.210:8080/api/product/get/all');
      setState(() {
        products = response.data;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void checkLoginStatus() async {
    SecureStorageService secureStorageService = SecureStorageService();
    String? token = await secureStorageService.getToken();
    print('가져와져라 $token');


    print('toekb');
    print(token);
    if (token != null) {
      print(30030);
      try {
        final response = await http.get(Uri.parse(
          'http://34.64.110.210:8080/users/readProfile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
        );
        final decodedResponseBody = utf8.decode(response.bodyBytes);
        print('Response status: ${response.body}');
        print(response.statusCode);
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(decodedResponseBody);
          setState(() {
            isLoggedIn = true;
            userName = data['name']; // 서버에서 반환된 name 값을 가져옴
          });
        } else {
          setState(() {
            isLoggedIn = false;
          });
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          isLoggedIn = false;
        });
      }
    } else {
      setState(() {
        isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              'android/assets/images/image.jpg', // 이미지 경로
              width: double.infinity,
              height: 230,
              fit: BoxFit.cover,
            ),
            isLoggedIn
                ? _buildLoggedInUI()  // 로그인된 경우
                : _buildLoggedOutUI(),  // 로그인되지 않은 경우
            SizedBox(height: 15), // 버튼과 리스트 사이의 간격
            SizedBox(
              height: 130, // 제품 리스트 높이 설정
              child: products.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        ClipOval(
                          child: Image.network('http://34.64.110.210:8080/' +
                            products[index]['image'],
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(products[index]['name'],
                            style: TextStyle(fontSize: 16)),
                        Text('${products[index]['smallPrice']}원',
                            style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 23), // 리스트 사이의 간격
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),  // 패딩 설정
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.asset(
                      'android/assets/images/image.jpg',
                      width: double.infinity,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.asset(
                      'android/assets/images/image.jpg',
                      width: double.infinity,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.asset(
                      'android/assets/images/image.jpg',
                      width: double.infinity,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 로그인하지 않은 상태의 UI
  Widget _buildLoggedOutUI() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      child: SizedBox(
        width: double.infinity,
        height: 110,
        child: Column(
          children: [
            Text(
              "반갑습니다.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "로그인 후 이용해 주세요.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TermsOfUseScreen()),
                    );
                  },
                  child: Text("회원가입"),
                ),
                SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                    // 로그인 버튼이 눌렸을 때의 동작
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  },
                  child: Text("로그인"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 로그인한 상태의 UI
  Widget _buildLoggedInUI() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 110,
            child: OutlinedButton(
              onPressed: () {
                // "내정보 확인" 버튼이 눌렸을 때의 동작
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyPageScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "반갑습니다. $userName님", // 서버에서 받아온 사용자 이름
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "내정보 확인",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey),
                ],
              ),
            ),
          ),
          SizedBox(height: 15), // 내 정보 확인하기 버튼 아래에 간격 추가
        ],
      ),
    );
  }
}


class OrderContent extends StatefulWidget {
  final int storeId; // 매장 ID
  final String orderMode; // 매장이용 또는 To-Go 정보

  // 생성자에서 storeId와 orderMode를 받도록 수정
  OrderContent({required this.storeId, required this.orderMode});

  @override
  _OrderContentState createState() => _OrderContentState();
}

class _OrderContentState extends State<OrderContent> {
  List<dynamic> products = [];
  final ApiService apiService = ApiService();
  String tokentest = ''; // token 저장 변수 추가

  @override
  void initState() {
    super.initState();
    fetchProducts();
    fetchToken();
  }

  // 토큰을 가져오는 함수
  void fetchToken() async {
    SecureStorageService storageService = SecureStorageService();
    String? token = await storageService.getToken();
    setState(() {
      tokentest = token ?? ''; // 토큰을 변수에 저장
    });
  }

  void fetchProducts() async {
    try {
      Response response = await apiService.getRequest('http://34.64.110.210:8080/api/product/get/all');
      setState(() {
        products = response.data;
        print(products);
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: products.isEmpty
          ? Center(child: CircularProgressIndicator()) // 로딩 중일 때 표시
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          print("Product data: ${products[index]}");
          return ListTile(
            leading: Image.network(
              'http://34.64.110.210:8080/' +
              products[index]['image'],
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error);
              },
            ),
            title: Text(products[index]['name']),
            subtitle: Text(products[index]['smallPrice'].toString()),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailScreen(
                    product: products[index],  // 제품 정보 전달
                    storeId: widget.storeId.toString(),  // storeId 전달
                    orderOption: widget.orderMode, // orderOption 전달 (매장 이용 또는 To-Go)
                    tk : tokentest,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class OtherContent extends StatefulWidget {
  @override
  _OtherContentState createState() => _OtherContentState();
}

class _OtherContentState extends State<OtherContent> {
  bool isLoading = true;
  bool isButtonEnabled = false;
  String userName = ""; // 기본 이름
  final SecureStorageService _storageService = SecureStorageService(); // SecureStorageService 인스턴스 생성

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // 사용자 정보 요청
  }

  Future<void> _fetchUserProfile() async {
    try {
      SecureStorageService storageService = SecureStorageService();
      String? token = await storageService.getToken();
      print("제발2 $token");
      final response = await http.get(
        Uri.parse('http://34.64.110.210:8080/users/readProfile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      final decodedResponseBody = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(decodedResponseBody);
        setState(() {
          userName = data['name']; // 받아온 사용자 이름으로 변경
          isButtonEnabled = true;  // 성공적으로 로드되면 버튼 활성화
        });
      } else {
        setState(() {
          isButtonEnabled = false; // 실패 시 버튼 비활성화
        });
      }
    } catch (e) {
      setState(() {
        isButtonEnabled = false; // 예외 발생 시 버튼 비활성화
      });
      print('사용자 정보 불러오기 실패: $e');
    } finally {
      setState(() {
        isLoading = false; // 로딩 완료
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        color: Color(0xFFF2F2F2), // 배경색을 회색으로 설정
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "$userName님\n환영합니다!!", // 받아온 이름을 표시
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            // 4개의 버튼을 균등하게 배치할 수 있도록 Row 수정
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOptionButton(
                    context, Icons.person, "마이페이지", MyPageScreen()),
                _buildOptionButton(
                    context, Icons.receipt_long, "주문내역", OrderListScreen()),
                _buildOptionButton(
                    context, Icons.card_giftcard, "쿠폰", CouponScreen()),
                _buildOptionButton(
                    context, Icons.shopping_cart, "장바구니", ShoppingCartScreen(orderoption : '매장 이용')), // 장바구니 버튼 추가
              ],
            ),
            SizedBox(height: 20),
            ListTile(
              title: Text("이용약관"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: isButtonEnabled
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TermsScreen()),
                );
              }
                  : null, // 비활성화 상태면 동작하지 않도록 설정
            ),
            Divider(),
            ListTile(
              title: Text("이벤트"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: isButtonEnabled ? () {
                // 이벤트 화면으로 이동
              } : null, // 비활성화 상태면 동작하지 않음
            ),
            Divider(),
            ListTile(
              title: Text("고객의 소리"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: isButtonEnabled ? () {
                // 고객의 소리 화면으로 이동
              } : null, // 비활성화 상태면 동작하지 않음
            ),
            Spacer(),
            Center(
              child: TextButton(
                onPressed: () async {
                  await _logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomeContent()),
                        (route) => false,
                  );
                },
                child: Text(
                  "로그아웃",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
      BuildContext context, IconData icon, String text, Widget targetScreen) {
    return GestureDetector(
      onTap: isButtonEnabled
          ? () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      }
          : null, // 비활성화 상태면 동작하지 않음
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(icon, size: 30, color: isButtonEnabled ? Colors.black : Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isButtonEnabled ? Colors.black : Colors.grey, // 버튼 비활성화 시 색상 회색
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await _storageService.deleteToken();
      print('로그아웃 성공');
    } catch (e) {
      print('로그아웃 실패: $e');
    }
  }
}

  void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}
