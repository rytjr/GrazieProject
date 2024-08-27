/*import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:fluttertest/Post.dart';
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

  final _apiClient = ApiService();
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
      final menuItems = await _apiClient.fetchMenuItems();
      setState(() {
        _menuItems = menuItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '메뉴를 불러오는 중 오류 발생: $e';
        _isLoading = false;
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


  static List<Widget> _widgetOptions(List<String> imageUrls, List<MenuItem> recommendedMenus) => <Widget>[
    HomeContent(imageUrls: imageUrls, recommendedMenus: recommendedMenus), // 여러 개의 이미지를 받고 추천 메뉴도 받는 HomeContent로 변경
    Text('Index 1: Order'),
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
      body: FutureBuilder<Post?>(
        future: post,
        builder: (context, postSnapshot) {
          if (postSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (postSnapshot.hasError) {
            return Center(child: Text('Error: ${postSnapshot.error}'));
          } else if (!postSnapshot.hasData || postSnapshot.data == null) {
            return Center(child: Text('No image found'));
          } else {
            List<String> imageUrls = postSnapshot.data!.imageUrls;

            return FutureBuilder<List<MenuItem>?>(
              future: recommendedMenus,
              builder: (context, recommendedSnapshot) {
                if (recommendedSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (recommendedSnapshot.hasError) {
                  return Center(child: Text('Error: ${recommendedSnapshot.error}'));
                } else if (!recommendedSnapshot.hasData || recommendedSnapshot.data == null) {
                  return Center(child: Text('No recommended menu found'));
                } else {
                  return HomeContent(
                    imageUrls: imageUrls,
                    recommendedMenus: recommendedSnapshot.data!,
                  );
                }
              },
            );
          }
        },
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedIndex == 1)
            Container(
              color: Colors.black87,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '구리인창DT ($selectedOption)',
                    style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
              width: double.infinity,
            ),
          BottomNavigationBar(
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
        ],
      ),
    );
  }
}
class HomeContent extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // 이미지 섹션
        /*ListView.builder(
          physics: NeverScrollableScrollPhysics(),  // 내부 스크롤 비활성화
          shrinkWrap: true,  // ListView가 다른 스크롤러블 위젯 안에 있을 때 사용
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.network(
                    imageUrls[index],
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text('Failed to load image'),
                      );
                    },
                  ),
                  SizedBox(height: 16.0),
                  if (index == 0) ...[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(16.0),
                        backgroundColor: Colors.white, // 버튼의 배경색
                        foregroundColor: Colors.black, // 버튼 텍스트 색상
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        // 버튼 클릭 시 동작
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '반갑습니다. 구교석님',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                              color: Colors.grey.shade200,
                            ),
                            child: Text(
                              'Coupon',
                              style: TextStyle(
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '내정보 확인',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.blue, // 텍스트 색상
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        // 추천 메뉴 섹션
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '추천 메뉴',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          height: 150,  // 추천 메뉴 리스트뷰 높이 설정
          child: ListView.builder(
            scrollDirection: Axis.horizontal,  // 가로 스크롤
            itemCount: recommendedMenus.length,
            itemBuilder: (context, index) {
              final menuItem = recommendedMenus[index];

              return GestureDetector(
                onTap: () {
                  // 메뉴 선택 시 상세 정보로 이동 등 추가 기능 구현 가능
                },
                child: Container(
                  width: 120,
                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        menuItem.imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error);
                        },
                      ),
                      SizedBox(height: 8.0),
                      Text(menuItem.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(menuItem.price, style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),*/
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}
*/