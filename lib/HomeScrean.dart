import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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
      isScrollControlled: true, // 이 설정을 통해 모달창을 전체 화면으로 확장할 수 있습니다.
      builder: (BuildContext context) {
        // 화면 크기를 계산합니다.
        final double screenHeight = MediaQuery.of(context).size.height;
        return Container(
          height: screenHeight - 50, // 상단에서 100만큼의 공간을 남깁니다.
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0), // 상단 왼쪽 모서리 둥글게
              topRight: Radius.circular(20.0), // 상단 오른쪽 모서리 둥글게
            ),
          ),
          child: Center(
            child: Text(
              '주문 정보를 입력하세요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  static List<Widget> _widgetOptions = <Widget>[
    HomeContent(),
    Text(
      'Index 1: Order',
    ),
    Text(
      'Index 2: Other',
    ),
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
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
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
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // 배경색을 하얀색으로 설정
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text(
            '2024.7.10 | DAILY',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '반갑습니다. 구교석님',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Coupon',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          Image.asset('assets/images/mango_smoothie.jpeg'), // 이미지 경로 수정 필요
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}
