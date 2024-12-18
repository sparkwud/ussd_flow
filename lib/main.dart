import 'package:flutter/material.dart';
import 'package:ussd_flow/screens/ussd_test_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'USSD Flow',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: UssdTestScreen(),
    );
  }
}
