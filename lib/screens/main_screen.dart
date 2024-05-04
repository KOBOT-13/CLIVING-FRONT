import 'package:cliving_front/screens/calendar_screen.dart';
import 'package:curved_nav_bar/curved_bar/curved_action_bar.dart';
import 'package:curved_nav_bar/fab_bar/fab_bottom_app_bar_item.dart';
import 'package:curved_nav_bar/flutter_curved_bottom_nav_bar.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'camera_screen.dart';
// ignore_for_file: prefer_const_constructors

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(padding: EdgeInsets.zero),
        bottomNavigationBar: CurvedNavBar(
          actionButton: //카메라
              CurvedActionBar(
                  onTab: (value) {
                    /// perform action here
                  },
                  activeIcon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: Icon(
                      Icons.camera,
                      size: 50,
                      color: Colors.black,
                    ),
                  ),
                  inActiveIcon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white70, shape: BoxShape.circle),
                    child: Icon(
                      Icons.camera,
                      size: 50,
                      color: Colors.black,
                    ),
                  ),
                  text: "카메라"),
          activeColor: Colors.black,
          navBarBackgroundColor: Colors.white,
          inActiveColor: Colors.black45,
          appBarItems: [
            FABBottomAppBarItem(
                activeIcon: Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.black,
                ),
                inActiveIcon: Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.black26,
                ),
                text: '캘린더'),
            FABBottomAppBarItem(
                activeIcon: Icon(
                  Icons.settings,
                  color: Colors.black,
                ),
                inActiveIcon: Icon(
                  Icons.settings,
                  color: Colors.black26,
                ),
                text: '설정'),
          ],
          bodyItems: [
            CalendarScreen(),
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.grey,
              child: Center(
                child: Text(
                  '설정이 구현될 화면입니다.',
                ),
              ),
            )
          ],
          actionBarView:
            Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: Colors.grey,
            child: Center(
              child: CameraScreen(),
            ),
          ),
        ));
  }
}
