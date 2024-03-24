import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class EntryScreen extends StatelessWidget {
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CLIVING',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 70,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -3),
              textAlign: TextAlign.end,
            )
          ],
        ),
      ),
    );
  }
}
