import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'PasswordNewscreen.dart'; // PasswordNewscreen 파일 import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StartScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  Future<void> _initDeepLinkListener() async {
    // 딥링크를 감지하고 화면을 이동시키는 코드
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.path == '/reset_password') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PasswordNewscreen()),
        );
      }
    }, onError: (err) {
      print("딥링크 오류 발생: $err");
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text('딥링크를 통한 화면 전환을 테스트하세요.'),
      ),
    );
  }
}
