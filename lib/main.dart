import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertest/HomeScrean.dart'; // 메인 화면 파일을 임포트

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 상태 표시줄 아이콘을 검은색으로, 시간은 하얀색으로 설정
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 상태 표시줄 배경을 투명하게 설정
      statusBarIconBrightness: Brightness.dark, // 상태 표시줄 아이콘을 검은색으로 설정
      statusBarBrightness: Brightness.light, // 상태 표시줄 시간 색상을 하얀색으로 설정 (iOS에서만 적용)
    ));

    return MaterialApp(
      home: StartScreen(),
    );
  }
}

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  void initState() {
    super.initState();
    // 데이터를 미리 로드하고 메인 화면으로 이동
    loadData().then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }

  Future<void> loadData() async {
    // 데이터 로드 시뮬레이션 (예: 네트워크 요청)
    await Future.delayed(Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF5B1333), // 그라찌에 색상
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0), // 모서리를 둥글게 설정
          child: Image.asset('android/assets/images/grazie_logo.jpeg'), // 로고 이미지 경로
        ),
      ),
    );
  }
}
