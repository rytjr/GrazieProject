import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fluttertest/ProductDetailScreen.dart';
import 'package:fluttertest/TermsOfUseScreen.dart';
import 'package:fluttertest/ApiService.dart';
import 'package:fluttertest/MenuItem.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String selectedStore = "구리인창DT"; // 기본 매장
  String selectedOption = "매장 이용"; // 기본 옵션



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
                child: ListView(
                  children: <Widget>[
                    _buildStoreTile(
                      '구리인창DT',
                      '경기도 구리시 건원대로 53 (인창동)',
                      '579m',
                      'android/assets/images/Grazie2.jpg',
                    ),
                    _buildStoreTile(
                      '구리동대리',
                      '경기도 구리시 경방로 5, 우진빌딩 (수택동)',
                      '595m',
                      'android/assets/images/order.png',
                    ),
                    _buildStoreTile(
                      '다산아이파트',
                      '경기도 남양주시 도농로 24 (다산동, 북양마을)',
                      '1.2km',
                      'android/assets/images/order.png',
                    ),
                    _buildStoreTile(
                      '다산DT',
                      '경기도 남양주시 다산중앙로 19번길 5 (다산동)',
                      '1.4km',
                      'android/assets/images/order.png',
                    ),
                    _buildStoreTile(
                      '도농역',
                      '경기도 남양주시 다산길 230 (다산동)',
                      '1.4km',
                      'android/assets/images/order.png',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  void showStoreDetailsModal(BuildContext context, String title, String address, String imagePath, String operatingHours, String additionalInfo) {
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
                    Image.asset(imagePath, width: MediaQuery.of(context).size.width, height: 200, fit: BoxFit.cover),
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
                        pickupButton(context, Icons.local_cafe, "매장 이용"),
                        pickupButton(context, Icons.shopping_bag, "To-Go"),
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

  Widget pickupButton(BuildContext context, IconData icon, String text) {
    return GestureDetector(
      onTap: () {
        // 모든 열려 있는 모달을 닫고 Order 페이지로 이동
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.pushReplacementNamed(context, '/order'); // '/order'는 Order 페이지로 이동하기 위한 라우트
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


  Widget _buildStoreTile(String title, String subtitle, String distance, String imagePath) {
    return GestureDetector(
      onTap: () => showStoreDetailsModal(
          context,
          title,
          subtitle,
          imagePath,
          "운영 시간: 07:00 - 21:30",
          "24시간 운영 주말 15시 - 18시, DT로 전환 시간대 조정 가능합니다."
      ),
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
                child: Image.asset(imagePath, width: 90, height: 90, fit: BoxFit.cover),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 8.0, bottom: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(distance, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
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


  static List<Widget> _widgetOptions() => <Widget>[
    HomeContent(),
    OrderContent(),
    Text('Index 2: Other'),
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
        leading: SizedBox(), // 왼쪽에 빈 공간 추가
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            color: Color(0xFF5B1333),
            onPressed: () {
              // 알림 아이콘 클릭 시의 동작을 여기에 추가하세요.
            },
          ),
        ],
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

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void fetchProducts() async {
    try {
      var dio = Dio();
      Response response = await dio.get('http://10.0.2.2:8000/api/product/get/all');
      setState(() {
        products = response.data;
      });
    } catch (e) {
      print('Error: $e');
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
                ? _buildLoggedInUI() // 로그인 상태에 따른 UI
                : _buildLoggedOutUI(),
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
                          child: Image.network(
                            products[index]['image'],
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(products[index]['name'],
                            style: TextStyle(fontSize: 16)),
                        Text('${products[index]['price']}원',
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
      child: SizedBox(
        width: double.infinity,
        height: 110,
        child: OutlinedButton(
          onPressed: () {
            // "내정보 확인" 버튼이 눌렸을 때의 동작
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
                    "반갑습니다. 구교석님",
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
    );
  }
}

class OrderContent extends StatefulWidget {
  @override
  _OrderContentState createState() => _OrderContentState();
}

class _OrderContentState extends State<OrderContent> {
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void fetchProducts() async {
    try {
      var dio = Dio();
      Response response = await dio.get(
          'http://10.0.2.2:8000/api/product/get/all');
      print("하이");
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
          print('Image URL: ${products[index]['image']}');
          return ListTile(
            leading: Image.network(
              products[index]['image'],
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                print('Image load error: $error'); // 오류 메시지를 출력
                return Icon(Icons.error);
              },
            ),
            title: Text(products[index]['name']),
            subtitle: Text(products[index]['price'].toString()),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProductDetailScreen(
                        product: products[index],
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
void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}
