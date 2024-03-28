import 'package:curved_nav_bar/curved_bar/curved_action_bar.dart';
import 'package:curved_nav_bar/fab_bar/fab_bottom_app_bar_item.dart';
import 'package:curved_nav_bar/flutter_curved_bottom_nav_bar.dart';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
// ignore_for_file: prefer_const_constructors

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime today = DateTime.now();
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      today = selectedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
          padding: EdgeInsets.fromLTRB(20, 80, 20, 30),
          child: Container(),
        ),
        bottomNavigationBar: CurvedNavBar(
          actionButton: CurvedActionBar(
              onTab: (value) {
                /// perform action here
                print(value);
              },
              activeIcon: Container(
                padding: EdgeInsets.all(8),
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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
              text: "Camera"),
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
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 30),
                child: TableCalendar(
                  locale: "en_US",
                  headerStyle: HeaderStyle(
                      formatButtonVisible: false, titleCentered: true),
                  availableGestures: AvailableGestures.all,
                  selectedDayPredicate: (day) => isSameDay(day, today),
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2024, 12, 31),
                  focusedDay: today,
                  onDaySelected: _onDaySelected,
                  calendarStyle: CalendarStyle(
                      defaultTextStyle: TextStyle(color: Colors.grey),
                      weekendTextStyle: TextStyle(color: Colors.grey),
                      markerDecoration: BoxDecoration(
                          color: Colors.blue[200], shape: BoxShape.circle)),
                  eventLoader: (day) {
                    if (day.day % 2 == 0) {
                      return ['hi'];
                    }
                    return [];
                  },
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.pinkAccent,
            )
          ],
          actionBarView: Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.orange,
          ),
        )

        //   // onTap: (int index) {
        //   //   switch (index) {
        //   //     case 0:
        //   //       Navigator.pushNamed(context, '/');
        //   //       break;
        //   //     case 1:
        //   //       Navigator.pushNamed(context, '/');
        //   //       break;
        //   //     default:
        //   //   }
        //   // },
        //   items: const [
        //     CurvedNavigationBarItem(child: Icon(Icons.home), label: '캘린더'),
        //     CurvedNavigationBarItem(child: Icon(Icons.camera), label: '카메라'),
        //     CurvedNavigationBarItem(
        //         child: Icon(Icons.account_circle), label: '마이페이지'),
        //   ],
        // ),
        );
  }
}
