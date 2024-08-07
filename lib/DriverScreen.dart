// lib/screens/first_screen.dart
import 'package:flutter/material.dart';

class DriverScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('This is Driver Screen'),
          ],
        ),
      ),
    );
  }
}