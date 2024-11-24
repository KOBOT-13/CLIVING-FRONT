import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../services/password_find_api.dart';
import '../services/number_formatter.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class FindPasswordScreen extends StatefulWidget {
  const FindPasswordScreen({super.key});

  @override
  State<FindPasswordScreen> createState() => _FindPasswordScreenState();
}

class _FindPasswordScreenState extends State<FindPasswordScreen> {
  final _idController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _verificationCodeContoroller = TextEditingController();
  PasswordFindApi pf = PasswordFindApi();
  int remainingTime = 180; // 타이머 시간(초)
  Timer? timer; // 타이머 객체
  bool isVerify = false;

  @override
  void dispose() {
    _idController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      _verificationCodeContoroller.text = "";
      isVerify = true;
      remainingTime = 180; // 3분으로 초기화
    });

    // 타이머 설정: 1초마다 실행
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--; // 남은 시간 감소
        } else {
          isVerify = false; // 시간이 끝나면 필드 숨김
          timer.cancel(); // 타이머 종료
        }
      });
    });
  }

  Future<void> handlePasswordFind() async {
    bool check =
        await pf.VerifyUser(_idController.text, _phoneNumberController.text);
    if (!check) {
      Get.snackbar("인증 오류", "아이디가 존재하지 않거나\n전화번호와 매치되지 않습니다.",
          snackPosition: SnackPosition.BOTTOM);
    } else {
      startTimer();
      check = await pf.SendVerify(_phoneNumberController.text);
      if (check) {
        Get.snackbar("인증번호 전송", "인증번호가 전송되었습니다.",
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar("인증번호 전송 실패", "서버 오류 혹은 네트워크 오류입니다.",
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<void> handleVerifyCode() async {
    bool check = await pf.CheckVerify(
        _phoneNumberController.text, _verificationCodeContoroller.text);

    if (check) {
      // 스크린 이동
    } else {
      Get.snackbar("인증 실패", "인증 번호를 다시 확인해주세요.",
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text(
          "비밀번호 찾기",
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomOpacity: 2.0,
        backgroundColor: Colors.white,
        shape: const Border(
            bottom: BorderSide(
          color: Color.fromRGBO(0, 0, 0, 0.2),
          width: 2,
        )),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("아이디와 전화번호를 입력해 주세요."),
                  const Gap(10),
                  TextField(
                    controller: _idController,
                    decoration: const InputDecoration(
                        labelText: '아이디',
                        floatingLabelStyle: TextStyle(color: Colors.blue),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 1),
                        )),
                  ),
                  const Gap(20),
                  TextField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(
                      labelText: '전화번호',
                      floatingLabelStyle: TextStyle(color: Colors.blue),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 1),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                      NumberFormatter(),
                      LengthLimitingTextInputFormatter(13)
                    ],
                  ),
                  const Gap(24),
                  ElevatedButton(
                    onPressed: () {
                      handlePasswordFind();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(50, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )),
                    child: const Text(
                      "전화번호 인증",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const Gap(30),
                  if (isVerify)
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: TextField(
                            controller: _verificationCodeContoroller,
                            textAlign: TextAlign.center,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6)
                            ],
                            decoration: const InputDecoration(
                              hintText: "인증번호 입력",
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10), // 텍스트 여백
                            ),
                          )),
                          Text(
                            "${(remainingTime ~/ 60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}", // 분:초 형태로 표시
                            style: const TextStyle(
                              color: Colors.red, // 타이머 색상
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(15),
                        ],
                      ),
                    ),
                  if (isVerify)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Gap(20),
                        ElevatedButton(
                          onPressed: () {
                            handleVerifyCode();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              minimumSize: const Size(50, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              )),
                          child: const Text(
                            "인증",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    )
                ],
              ),
            )),
      ),
    );
  }
}
