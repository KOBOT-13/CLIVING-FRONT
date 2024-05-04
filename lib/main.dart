import 'package:cliving_front/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/entry_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Pretendard'),
      home: const MainScreen(),
    );
  }
}
