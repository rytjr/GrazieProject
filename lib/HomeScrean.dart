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
  int a = 0;
  int num = 100;



  @override
  void initState() {
    super.initState();
    print("initState 실행");
    Future.delayed(Duration.zero, () {
      fetchStores();
    });
  }

  Future<void> fetchStores() async {
    try {
      final url = 'http://34.64.110.210:8080/api/store/get/all';
      print("URL 요청 시작");
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      final responseBody = utf8.decode(response.bodyBytes); // UTF-8로 디코딩
      print("응답 코드: ${responseBody}");

      if (response.statusCode == 200) {
        print("매장 응답 : ${response.body}");
        final responseData = json.decode(responseBody); // 디코딩 후 JSON 파싱;
        print("응답 코드: ${responseData}");
        setState(() {
          stores = responseData;
          isLoading = false;
        });
      } else {
        print('Order submission failed: ${response.body}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error during order submission: $e');
      setState(() {
        isLoading = false;
      });
    }
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // 특정 인덱스에서 추가 작업을 수행하려면 조건 추가 가능
    if (index == 1) {
      _showOrderModal(context); // 예시: Order Modal을 표시
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
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    return _buildStoreTile(
                      stores[index]['name'],
                      stores[index]['location'],
                      stores[index],
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

  void showStoreDetailsModal(BuildContext context, String title, String address, Map<String, dynamic> operatingHours, String roadWay, bool parking, dynamic store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final double screenHeight = MediaQuery.of(context).size.height;

        // 운영 시간 표시 생성 함수
        String formatOperatingHours(Map<String, dynamic> hoursData) {
          List<String> formattedHours = [];

          // 영어 요일을 한국어 요일로 변환하는 매핑
          Map<String, String> dayMapping = {
            "Monday": "월요일",
            "Tuesday": "화요일",
            "Wednesday": "수요일",
            "Thursday": "목요일",
            "Friday": "금요일",
            "Saturday": "토요일",
            "Sunday": "일요일"
          };

          hoursData.forEach((day, times) {
            if (times != null && times is Map) {
              final openTimeStr = times['open'] ?? "00:00:00";
              final closeTimeStr = times['close'] ?? "00:00:00";

              // 문자열 시간 데이터를 DateTime 형식으로 파싱하여 시간과 분 추출
              final openTime = DateTime.parse("1970-01-01 $openTimeStr");
              final closeTime = DateTime.parse("1970-01-01 $closeTimeStr");

              // 영어 요일을 한국어 요일로 변환
              String formattedDay = "${dayMapping[day] ?? day}: ${openTime.hour.toString().padLeft(2, '0')}:${openTime.minute.toString().padLeft(2, '0')} - ${closeTime.hour.toString().padLeft(2, '0')}:${closeTime.minute.toString().padLeft(2, '0')}";
              formattedHours.add(formattedDay);
            } else {
              formattedHours.add("${dayMapping[day] ?? day}: 정보 없음");
            }
          });

          return formattedHours.join("\n");
        }

// 운영 시간 및 휴일 텍스트 생성
        String operatingHoursText = formatOperatingHours(operatingHours['days'] ?? {});
        String holidaysText = formatOperatingHours(operatingHours['holidays'] ?? {});

        return Container(
          height: screenHeight - 60,
          color: Colors.white,
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
                    Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    Text(address, style: TextStyle(fontSize: 18, color: Colors.grey[800])),
                    SizedBox(height: 10),
                    Text("운영 시간", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(operatingHoursText, style: TextStyle(fontSize: 16)),
                    SizedBox(height: 10),
                    Text("휴일", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(holidaysText, style: TextStyle(fontSize: 16, color: Colors.red)),
                    SizedBox(height: 20),
                    Text("추가 정보", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("도로명 주소: $roadWay\n주차 가능 여부: ${parking ? '가능' : '불가'}", style: TextStyle(fontSize: 16)),
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
                        pickupButton(context, Icons.local_cafe, "매장", store),
                        pickupButton(context, Icons.shopping_bag, "픽업", store),
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
        int storeIdInt = int.tryParse(store['store_id'].toString()) ?? 0; // 변환 실패 시 0 할당

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



  Widget _buildStoreTile(String? title, String? subtitle, dynamic store) {
    return GestureDetector(
      onTap: () {
        showStoreDetailsModal(
          context,
          title ?? '매장 이름 없음',
          subtitle ?? '매장 주소 없음',
          store['operatingHours'] ?? {}, // 운영 시간
          store['road_way'] ?? '주소 없음', // 도로명 주소
          store['parking'] ?? false, // 주차 가능 여부
          store, // 네 번째 인자로 store 전달
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6.0),
          height: 110,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.store,
                size: 90.0,
                color: Colors.grey, // Adjust the color as needed
              ),
              SizedBox(width: 10), // Space between the icon and the text
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title ?? '매장 이름 없음',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        subtitle ?? '매장 주소 없음',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        // backgroundColor: Color(0xFFFFFFFF).withOpacity(0.6), // 투명도 60%
        title: Transform.translate(
          offset: Offset(0, 0), // 오른쪽으로 10만큼 이동
          child: Text(
            'Grazie',
            style: TextStyle(
              color: Color(0xFF5B1333),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true, // 타이틀 중앙 정렬
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
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
  String userName = ''; // 사용자 이름 저장 변수
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      fetchProducts();
      checkLoginStatus(); // 로그인 상태 확인 먼저 실행
    });
  }

  void fetchProducts() async {
    try {
      Response response = await apiService.getRequest(
          'http://34.64.110.210:8080/api/product/get/all');
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

    if (token != null) {
      try {
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
      backgroundColor: Colors.white,
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
                ? _buildLoggedInUI() // 로그인된 경우
                : _buildLoggedOutUI(), // 로그인되지 않은 경우
            SizedBox(height: 15), // 버튼과 리스트 사이의 간격
            SizedBox(height: 2),
            SizedBox(
              height: 130, // 제품 리스트 높이 설정
              child: products.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // 제품을 누르면 OrderContent 화면으로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailScreen(
                                product: products[index],
                                // 제품 정보 전달
                                storeId: '2',
                                // storeId 전달
                                orderOption: '매장 이용',
                                // orderOption 전달 (매장 이용 또는 To-Go)
                                tk: '',
                              ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          ClipOval(
                            child: SizedBox(
                              width: 85,
                              height: 70,
                              child: Image.network(
                                'http://34.64.110.210:8080/' +
                                    products[index]['image'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error);
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            products[index]['name'],
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${products[index]['smallPrice']}원',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 5), // 리스트 사이의 간격
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 0), // 패딩 설정
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.asset(
                      'android/assets/images/event4.png',
                      width: double.infinity,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.asset(
                      'android/assets/images/event2.png',
                      width: double.infinity,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.asset(
                      'android/assets/images/event3.png',
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
        height: 120,
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
                      MaterialPageRoute(
                          builder: (context) => TermsOfUseScreen()),
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

  Widget _buildLoggedInUI() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 100,
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
              child: Padding(
                padding: const EdgeInsets.only(left: 60),
                // Shift content 100 units to the right
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "반갑습니다. ",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: "$userName님", // 사용자 이름 부분
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5B1333), // 원하는 색상으로 변경
                                ),
                              ),
                            ],
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

  OrderContent({required this.storeId, required this.orderMode});

  @override
  _OrderContentState createState() => _OrderContentState();
}

class _OrderContentState extends State<OrderContent> {
  List<dynamic> products = [];
  List<dynamic> filteredProducts = [];
  final ApiService apiService = ApiService();
  String tokentest = ''; // token 저장 변수 추가
  String selectedCategory = '전체'; // 선택된 카테고리 기본값

  // 카테고리 목록
  List<String> categories = ['전체', 'Coffee', 'Tea Latte', 'Yogurt Smoothie', 'Bubble Tea', 'Frappe', 'Frappuccino', 'Etc'];

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

  // 제품 정보를 가져오는 함수
  void fetchProducts() async {
    try {
      Response response = await apiService.getRequest('http://34.64.110.210:8080/api/product/get/all');
      setState(() {
        products = response.data;
        filteredProducts = products; // 기본적으로 전체 제품을 표시
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  // 카테고리 변경 시 필터링하는 함수
  void filterProductsByCategory(String category) {
    setState(() {
      selectedCategory = category;
      if (category == '전체') {
        filteredProducts = products;
      } else {
        filteredProducts = products.where((product) => product['category'] == category).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('주문하기'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 카테고리 선택 탭
          Container(
            padding: EdgeInsets.symmetric(horizontal: 1, vertical: 5),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  return GestureDetector(
                    onTap: () => filterProductsByCategory(category),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1.0),
                      child: Chip(
                        label: Text(category),
                        backgroundColor: selectedCategory == category ? Color(0xFF5B1333) : Colors.white,
                        labelStyle: TextStyle(
                          color: selectedCategory == category ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(child: CircularProgressIndicator()) // 로딩 중일 때 표시
                : ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 30, // 60x60 크기로 설정
                    backgroundImage: NetworkImage(
                      'http://34.64.110.210:8080/' + filteredProducts[index]['image'],
                    ),
                    onBackgroundImageError: (error, stackTrace) {
                      print(error); // 로드 실패 시 처리
                    },
                  ),
                  title: Text(filteredProducts[index]['name']),
                  subtitle: Text('${filteredProducts[index]['smallPrice']}원'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          product: filteredProducts[index],
                          storeId: widget.storeId.toString(),
                          orderOption: widget.orderMode,
                          tk: tokentest,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 30, right: 30),
        child: FloatingActionButton(
          backgroundColor: Colors.black,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ShoppingCartScreen(
                  orderoption: widget.orderMode,
                  storeId: widget.storeId.toString(),
                ),
              ),
            );
          },
          child: Icon(Icons.shopping_cart, color: Colors.white),
        ),
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
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        color: Color(0xFFF2F2F2), // 배경색을 회색으로 설정
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: RichText(
                textAlign: TextAlign.center, // 텍스트 자체의 중앙 정렬
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$userName님\n",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5B1333),
                      ),
                    ),
                    TextSpan(
                      text: "반갑습니다.",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
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
                    context, Icons.shopping_cart, "장바구니", ShoppingCartScreen(orderoption : '',storeId: '2',)), // 장바구니 버튼 추가
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
            // ListTile(
            //   title: Text("이벤트"),
            //   trailing: Icon(Icons.arrow_forward_ios),
            //   onTap: isButtonEnabled ? () {
            //     // 이벤트 화면으로 이동
            //   } : null, // 비활성화 상태면 동작하지 않음
            // ),
            // Divider(),
            // ListTile(
            //   title: Text("고객의 소리"),
            //   trailing: Icon(Icons.arrow_forward_ios),
            //   onTap: isButtonEnabled ? () {
            //     // 고객의 소리 화면으로 이동
            //   } : null, // 비활성화 상태면 동작하지 않음
            // ),
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
