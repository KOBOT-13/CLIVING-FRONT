import 'dart:convert';

import 'package:cliving_front/charts/pie_chart.dart';
import 'package:cliving_front/screens/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

const Color selectedColor = Colors.white;
const Color normalColor = Colors.black54;

Widget _settingItems(String title, bool isLast, Function onTapAction) {
  return InkWell(
    onTap: () {
      onTapAction();
    },
    child: Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? const Border()
            : const Border(
                bottom: BorderSide(),
              ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
        ),
      ),
    ),
  );
}

class _MyPageScreenState extends State<MyPageScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isYearly = false;
  double xAlign = -1;
  Color monthColor = selectedColor;
  Color yearColor = normalColor;
  late Future<String> annualTime;
  late Future<String> monthlyTime;

  @override
  void initState() {
    super.initState();
    annualTime = _getAnnualTime();
    monthlyTime = _getMonthlyTime();
  }

  // 월 이동 함수
  void _goToPreviousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
    });
  }

  void _goToNextMonth() {
    if (_selectedDate.year < DateTime.now().year ||
        (_selectedDate.year == DateTime.now().year &&
            _selectedDate.month < DateTime.now().month)) {
      setState(() {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
      });
    }
  }

  // 연도 이동 함수
  void _goToPreviousYear() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year - 1, _selectedDate.month);
    });
  }

  void _goToNextYear() {
    if (_selectedDate.year < DateTime.now().year) {
      setState(() {
        _selectedDate = DateTime(_selectedDate.year + 1, _selectedDate.month);
      });
    }
  }

  // 이번 달로 돌아가기
  void _goToCurrentMonth() {
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  // 이번 연도로 돌아가기
  void _goToCurrentYear() {
    setState(() {
      _selectedDate = DateTime(DateTime.now().year, _selectedDate.month);
    });
  }

  Future<String> _getMonthlyTime() async {
    String apiAddress = dotenv.get("API_ADDRESS");
    final url = Uri.parse('$apiAddress/v1/statistics/monthly/climbing-time/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> readMonthlyTime =
          json.decode(utf8.decode(response.bodyBytes));
      return readMonthlyTime['total_climbing_time_hhmm'];
    } else {
      throw Exception('Failed to read Monthly Time.');
    }
  }

  Future<String> _getAnnualTime() async {
    String apiAddress = dotenv.get("API_ADDRESS");
    final url = Uri.parse('$apiAddress/v1/statistics/annual/climbing-time/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> readAnnualTime =
          json.decode(utf8.decode(response.bodyBytes));
      return readAnnualTime['total_climbing_time_hhmm'];
    } else {
      throw Exception('Failed to read Annual Time.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      width: double.infinity,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            color: Color.fromRGBO(46, 149, 210, 1),
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: const Color.fromARGB(255, 214, 240, 255),
                        elevation: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: Stack(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(top: 20),
                                    width: 100,
                                    height: 100,
                                    color: Colors.transparent,
                                  ),
                                  const Positioned(
                                    width: 80,
                                    height: 80,
                                    top: 12,
                                    left: 20,
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage: AssetImage(
                                          'assets/images/profile_image.png'),
                                      backgroundColor: Colors.transparent,
                                    ),
                                  ),
                                ],
                              ),
                              const Positioned(
                                top: 20,
                                left: 120,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "임혜진 님",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "3레벨 클라이머",
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SettingScreen()));
                                  },
                                  icon: const Icon(Icons.settings_sharp),
                                  iconSize: 23,
                                  color: Colors.grey[600],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                top: 5,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_left),
                                  onPressed: _isYearly
                                      ? _goToPreviousYear
                                      : _goToPreviousMonth,
                                ),
                              ),
                              Positioned(
                                left: 75,
                                top: 17,
                                child: Text(
                                  _isYearly
                                      ? '${_selectedDate.year}년'
                                      : '   ${DateFormat.MMMM('ko').format(_selectedDate)}  ', // 월 이름 포맷
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              Positioned(
                                left: 160,
                                top: 5,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_right),
                                  onPressed: _isYearly
                                      ? _goToNextYear
                                      : _goToNextMonth,
                                ),
                              ),
                              Positioned(
                                right: 85,
                                top: 6,
                                child: IconButton(
                                    onPressed: _isYearly
                                        ? _goToCurrentYear
                                        : _goToCurrentMonth,
                                    icon: const Icon(Icons.today_outlined)),
                              ),
                              Positioned(
                                right: 5,
                                top: 12,
                                child: Container(
                                  width: 80,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[350],
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(50.0),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      AnimatedAlign(
                                        alignment: Alignment(xAlign, 0),
                                        duration:
                                            const Duration(milliseconds: 300),
                                        child: Container(
                                          width: 80 * 0.5,
                                          height: 35,
                                          decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(50.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            xAlign = -1;
                                            monthColor = selectedColor;

                                            yearColor = normalColor;
                                            _isYearly = false;
                                          });
                                        },
                                        child: Align(
                                          alignment: const Alignment(-1, 0),
                                          child: Container(
                                            width: 80 * 0.5,
                                            color: Colors.transparent,
                                            alignment: Alignment.center,
                                            child: Text(
                                              '월별',
                                              style: TextStyle(
                                                color: monthColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            xAlign = 1;
                                            yearColor = selectedColor;

                                            monthColor = normalColor;
                                            _isYearly = true;
                                          });
                                        },
                                        child: Align(
                                          alignment: const Alignment(1, 0),
                                          child: Container(
                                            width: 80 * 0.5,
                                            color: Colors.transparent,
                                            alignment: Alignment.center,
                                            child: Text(
                                              '연별',
                                              style: TextStyle(
                                                color: yearColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 통계 그래프
                        Expanded(
                          child: Row(children: [
                            Expanded(
                              child: FutureBuilder<String>(
                                future: _isYearly ? annualTime : monthlyTime,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return const Center(
                                        child: Text('Error loading data'));
                                  } else {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            '클라이밍 시간',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            snapshot.data ?? 'N/A',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                            Expanded(
                                child: PieChartWidget(
                                    // dataType: 2,
                                    dataType: !_isYearly ? 1 : 2)),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Container(
                          width: double.maxFinite,
                          height: 0,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(),
                            ),
                          ),
                        ),
                        _settingItems(
                          "고객 지원 센터",
                          false,
                          () {
                            launchUrl(Uri.parse(''));
                          },
                        ),
                        _settingItems("작성한 게시물", false, () {}),
                        _settingItems("로그아웃", false, () {}),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
