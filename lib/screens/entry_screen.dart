import 'package:cliving_front/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  _EntryScreenState createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  @override
  void initState() {
    super.initState();

    // 일정 시간 후에 MainScreen으로 이동
    Timer(const Duration(seconds: 2), () {
      // 화면 전환
      Get.off(() => const MainScreen(), transition: Transition.cupertino);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Image.asset(
              'assets/images/entry.png',
              width: 330,
              height: 330,
            )
          ],
        ),
      ),
    );
  }
}
