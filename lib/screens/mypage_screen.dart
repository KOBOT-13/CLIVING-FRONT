import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cliving_front/charts/pie_chart.dart';
import 'package:cliving_front/screens/login_screen.dart';
import 'package:cliving_front/services/logout_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../controllers/auth_controller.dart';
import '../services/mypage_api.dart';

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
  final String API_ADDRESS = dotenv.get('API_ADDRESS');
  final LogoutApi logoutApi = LogoutApi();
  final authController = Get.find<AuthController>();
  Map<String, dynamic>? userProfile;
  DateTime _selectedDate = DateTime.now();
  bool _isYearly = false;
  double xAlign = -1;
  Color monthColor = selectedColor;
  Color yearColor = normalColor;
  late Future<String> annualTime;
  late Future<String> monthlyTime;
  late RxnString nickname;
  late RxnString profileImage;
  RxBool isEditing = false.obs;
  late TextEditingController nicknameController;

  XFile? _pickedFile;
  _getPhotoLibraryImage() async {
    final UserService userService = UserService(); // 인스턴스 생성
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 30 // 이미지 크기의 압축을 위해 퀄리티를 30으로 낮춤
        );
    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
      //서버에 이미지 업로드
      final result = await userService.updateProfileImage(
          pickedFile, authController.accessToken.value!);
      if (result != null) {
        print("프로필 업데이트 성공");
      } else {
        print("프로필 업데이트 실패");
      }
    } else {
      if (kDebugMode) {
        print('이미지 선택안함');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    nickname = authController.nickname;
    profileImage = authController.profileImage;

    annualTime = _getAnnualTime();
    monthlyTime = _getMonthlyTime();

    nicknameController =
        TextEditingController(text: authController.nickname.value);
  }

  @override
  void dispose() {
    nicknameController.dispose();
    super.dispose();
  }

  void saveUsername() async {
    // TextField에서 입력된 닉네임을 nickname 변수에 저장
    nickname.value = nicknameController.text;
    isEditing.value = false;

    // 닉네임이 비어 있지 않은 경우에만 서버에 업데이트 요청
    if (nickname.value != null && nickname.value!.isNotEmpty) {
      // 서버에 닉네임 업데이트 요청
      final response = await UserService().updateNickname(nickname.value!);

      if (response != null) {
        print("닉네임이 성공적으로 업데이트되었습니다.");
      } else {
        print("닉네임 업데이트 실패");
      }
    }
  }

  void cancelEdit() {
    // 수정 모드 종료
    isEditing.value = false;

    // authController에서 최신 닉네임 가져와서 nicknameController에 설정
    nicknameController.text = authController.nickname.value ?? '';

    // print("닉네임 초기화: ${authController.nickname.value}");
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

  final TextStyle textStyle = const TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 19,
    color: Colors.black,
  );

  final UnderlineInputBorder textFieldBorder = const UnderlineInputBorder(
    borderSide: BorderSide(
      color: Color.fromRGBO(46, 149, 210, 1), // 기본 밑줄 색상 (파란색)
      width: 1.0,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
                            Positioned(
                              width: 80,
                              height: 80,
                              top: 12,
                              left: 20,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(width: 2, color: Colors.white),
                                  boxShadow: [
                                    BoxShadow(
                                      spreadRadius: 1,
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.1),
                                    ),
                                  ],
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: (_pickedFile != null)
                                          ? FileImage(File(_pickedFile!.path))
                                              as ImageProvider
                                          : NetworkImage(authController
                                              .profileImage.value!)),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 5,
                              right: 0,
                              child: Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(width: 2, color: Colors.white),
                                  color: Colors.blue,
                                ),
                                child: GestureDetector(
                                  onTap: () => _getPhotoLibraryImage(),
                                  child: const Center(
                                    child: Icon(
                                      Icons.edit,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      size: 16, // Container 크기에 맞게 아이콘 크기를 조정
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 20,
                          left: 120,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(
                                () => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isEditing.value)
                                      SizedBox(
                                        width: 150,
                                        child: TextField(
                                          controller: nicknameController,
                                          autofocus: true,
                                          style: textStyle,
                                          decoration: InputDecoration(
                                            hintText:
                                                '${authController.nickname.value}',
                                            hintStyle: textStyle,
                                            border:
                                                InputBorder.none, // 기본 테두리 제거
                                            enabledBorder:
                                                textFieldBorder, // 활성화 상태 밑줄 스타일
                                            focusedBorder:
                                                const UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Colors
                                                    .blueAccent, // 포커스 시 진한 파란색 밑줄
                                                width: 1.5,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    bottom: 0),
                                            isDense: true,
                                            // contentPadding: EdgeInsets.zero
                                          ),
                                        ),
                                      )
                                    else
                                      Text("$nickname 님", style: textStyle),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    if (isEditing.value) ...[
                                      GestureDetector(
                                        onTap: saveUsername,
                                        child: const Icon(Icons.check,
                                            color: Colors.green, size: 18),
                                      ),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: cancelEdit,
                                        child: const Icon(Icons.close,
                                            color: Colors.red, size: 18),
                                      ),
                                    ] else
                                      GestureDetector(
                                        onTap: () {
                                          isEditing.value = true;
                                        },
                                        child: const Icon(Icons.edit, size: 18),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 7,
                              ),
                              const Text(
                                "클라이머",
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                            ],
                          ),
                        ),
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
                            onPressed:
                                _isYearly ? _goToNextYear : _goToNextMonth,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    "고객지원센터",
                    false,
                    () {
                      launchUrl(Uri.parse(''));
                    },
                  ),
                  _settingItems("작성한 게시물", false, () {}),
                  _settingItems("로그아웃", false, () async {
                    bool success = await logoutApi.logout();
                    if (success) {
                      Get.offAll(
                          () => const LoginScreen()); // 모든 화면을 닫고 로그인 화면으로 이동
                    } else {
                      Get.snackbar(
                          "Logout Failed", "Please try again."); // 실패 메시지 표시
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
