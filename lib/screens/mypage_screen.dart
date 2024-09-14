import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

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

  // 월/연도 전환 함수
  void _toggleMode() {
    setState(() {
      _isYearly = !_isYearly;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(top: 40),
                                width: 100,
                                height: 80,
                                color: Colors.transparent,
                              ),
                              const Positioned(
                                width: 80,
                                height: 80,
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: AssetImage(
                                      'assets/images/profile_image.png'),
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                            ],
                          ),

                          const Padding(
                            padding: EdgeInsets.fromLTRB(15, 5, 0, 0),
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
                          ), // 이름
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_left),
                        onPressed:
                            _isYearly ? _goToPreviousYear : _goToPreviousMonth,
                      ),
                      Text(
                        _isYearly
                            ? '${_selectedDate.year}년'
                            : DateFormat.MMMM('ko')
                                .format(_selectedDate), // 월 이름 포맷
                        style: const TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_right),
                        onPressed: _isYearly ? _goToNextYear : _goToNextMonth,
                      ),
                      IconButton(
                          onPressed:
                              _isYearly ? _goToCurrentYear : _goToCurrentMonth,
                          icon: const Icon(Icons.today_outlined)),
                      Container(
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
                              duration: const Duration(milliseconds: 300),
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
                                  _toggleMode();
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
                                  _toggleMode();
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
                    ],
                  ),

                  // 여기에 통계 그래프가 들어갑니다.
                  const Expanded(
                    child: Center(
                      child: Text(
                        '통계 그래프 표시 부분',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),

                  _settingItems(
                    "고객지원센터",
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
    );
  }
}
