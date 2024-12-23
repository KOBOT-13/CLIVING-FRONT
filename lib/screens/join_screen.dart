import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'dart:async';
import '../services/join_api.dart';
import '../widgets/custom_dialog.dart';

class NumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex <= 3) {
        if (nonZeroIndex % 3 == 0 && nonZeroIndex != text.length) {
          buffer.write('-'); // Add double spaces.
        }
      } else {
        if (nonZeroIndex % 7 == 0 &&
            nonZeroIndex != text.length &&
            nonZeroIndex > 4) {
          buffer.write('-');
        }
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  JoinApi api = JoinApi();

  final formKey = GlobalKey<FormState>();
  late String id;
  late String password;
  late String password2;
  late String nickname;
  String phoneNumber = "";
  String verificationCode = "";

  bool isIdValid = true;
  bool isPasswordValid = true;
  bool isPassword2Valid = true;
  bool isPhoneNumberValid = true;
  bool isVerify = false;
  bool isCheckId = false;
  bool isCheckNickname = false;

  bool openAuthCode = false;
  bool closeAuthCode = false;
  int remainingTime = 180; // 타이머 시간(초)
  Timer? timer; // 타이머 객체

  final passwordPattern =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$');

  @override
  void dispose() {
    timer?.cancel(); // 페이지 종료 시 타이머 취소
    super.dispose();
  }

  // 타이머 시작 함수
  void startTimer() {
    setState(() {
      openAuthCode = true;
      remainingTime = 180; // 3분으로 초기화
    });

    // 타이머 설정: 1초마다 실행
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--; // 남은 시간 감소
        } else {
          openAuthCode = false; // 시간이 끝나면 필드 숨김
          timer.cancel(); // 타이머 종료
        }
      });
    });
  }

  void postJoin() async {
    bool check =
        await api.postJoin(id, password, password2, nickname, phoneNumber);
    if (check) {
      showMyDialog(context, "회원가입 완료", "회원가입이 성공적으로 완료되었습니다.");
    } else {
      showMyDialog(context, "회원가입 실패", "입력한 정보를 다시 확인해주세요.");
    }
  }

  void sendVerificationCode() async {
    await api.verificationCode(phoneNumber);
  }

  void verifyCode() async {
    isVerify = await api.verifyPhoneCode(verificationCode, phoneNumber);
    if (isVerify) {
      showMyDialog(context, "전화번호 인증 완료", "회원가입을 진행해주세요.");
      closeAuthCode = true;
    } else {
      showMyDialog(context, "전화번호 인증 실패", "인증 번호가 일치하지 않습니다.");
      closeAuthCode = true;
    }
  }

  void checkUsername() async {
    bool check = await api.checkUsername(id);
    if (check) {
      showMyDialog(context, "아이디 중복 확인 완료", "사용 가능한 아이디입니다.");
    } else {
      showMyDialog(context, "아이디 중복 오류", "이미 존재하는 아이디입니다.");
    }
    isCheckId = check;
  }

  void checkNickname() async {
    bool check = await api.checkNickname(nickname);
    if (check) {
      showMyDialog(context, "닉네임 중복 확인 완료", "사용 가능한 닉네임입니다.");
    } else {
      showMyDialog(context, "닉네임 중복 오류", "이미 존재하는 닉네임입니다.");
    }
    isCheckNickname = check;
  }

  Future<bool> checkPhoneNumber() async {
    bool check = await api.checkPhoneNumber(phoneNumber);
    if (!check) {
      showMyDialog(context, "전화번호 중복 오류", "이미 존재하는 휴대폰 번호입니다.");
    }
    return check;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text(
            "회원가입",
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
          behavior: HitTestBehavior.opaque, // 빈 공간에서도 터치 감지
          child: Stack(
            children: [
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '아이디',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Gap(10),
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Row의 높이를 맞추기 위해 사용
                        children: [
                          Expanded(
                            child: TextFormField(
                              maxLength: 15,
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                                contentPadding: const EdgeInsets.only(left: 15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                helperText: '',
                              ),
                              cursorHeight: 15,
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '아이디를 입력해주세요.'; // 에러 메시지
                                }
                                return null;
                              },
                              onChanged: (value) {
                                id = value;
                              },
                            ),
                          ),
                          const Gap(10),
                          SizedBox(
                            width: 60,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                checkUsername();
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                ),
                                padding: EdgeInsets.zero,
                                elevation: 0,
                                backgroundColor:
                                    const Color.fromARGB(255, 101, 195, 250),
                              ),
                              child: const Text(
                                "중복 확인",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(10),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '비밀번호',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Gap(10),
                      TextFormField(
                        obscureText: true,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 15),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1.0,
                                )),
                            helperText: '',
                            errorText: isPasswordValid
                                ? null
                                : '비밀번호는 8자 이상, 영어 + 숫자 + 특수기호를 포함해야 합니다.'),
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                        onChanged: (value) {
                          setState(() {
                            isPasswordValid = passwordPattern.hasMatch(value);
                            password = value;
                          });
                        },
                        validator: (value) {
                          if (value!.isEmpty) {
                            return '비밀번호를 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      const Gap(10),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '비밀번호 확인',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Gap(10),
                      TextFormField(
                        obscureText: true,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 15),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 1.0,
                                )),
                            helperText: '',
                            errorText:
                                isPassword2Valid ? null : '비밀번호가 일치하지 않습니다.'),
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return '비밀번호 확인을 입력해주세요.';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            if (value != password)
                              isPassword2Valid = false;
                            else
                              isPassword2Valid = true;
                            password2 = value;
                          });
                        },
                      ),
                      const Gap(10), // 에러 메시지 및 공간 확보
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '닉네임',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Gap(10),
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Row의 높이를 맞추기 위해 사용
                        children: [
                          Expanded(
                            child: TextFormField(
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                labelStyle:
                                    const TextStyle(color: Colors.black),
                                contentPadding: const EdgeInsets.only(left: 15),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                helperText: '',
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '닉네임을 입력해주세요.'; // 에러 메시지
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  nickname = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10), // Row 내에서 버튼과 필드 사이의 간격 추가
                          SizedBox(
                            width: 60,
                            height: 50, // TextFormField와 동일한 높이
                            child: ElevatedButton(
                              onPressed: () {
                                checkNickname();
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                ),
                                padding: EdgeInsets.zero,
                                elevation: 0,
                                backgroundColor:
                                    const Color.fromARGB(255, 101, 195, 250),
                              ),
                              child: const Text(
                                "중복 확인",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(10), // 에러 메시지 및 공간 확보
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '전화번호 인증',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Gap(10),
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start, // Row의 높이를 맞추기 위해 사용
                        children: [
                          Expanded(
                            child: TextFormField(
                              cursorColor: Colors.black,
                              decoration: InputDecoration(
                                  labelStyle:
                                      const TextStyle(color: Colors.black),
                                  contentPadding:
                                      const EdgeInsets.only(left: 15),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: const BorderSide(
                                      color: Colors.black,
                                    ),
                                  ),
                                  helperText: '',
                                  errorText: isPhoneNumberValid
                                      ? null
                                      : '전화번호를 입력해주세요.'),
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return '전화번호를 입력해주세요.'; // 에러 메시지
                                }
                                return null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  phoneNumber = value;
                                });
                              },
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                                NumberFormatter(),
                                LengthLimitingTextInputFormatter(13)
                              ],
                            ),
                          ),
                          const SizedBox(width: 10), // Row 내에서 버튼과 필드 사이의 간격 추가
                          SizedBox(
                            width: 60,
                            height: 50, // TextFormField와 동일한 높이
                            child: ElevatedButton(
                              onPressed: () async {
                                bool check = await checkPhoneNumber();
                                setState(() {
                                  if (phoneNumber.length == 13) {
                                    if (check) {
                                      isPhoneNumberValid = true;
                                      closeAuthCode = false;
                                      sendVerificationCode();
                                      startTimer();
                                    }
                                  } else {
                                    isPhoneNumberValid = false;
                                  }
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                ),
                                padding: EdgeInsets.zero,
                                elevation: 0,
                                backgroundColor:
                                    const Color.fromARGB(255, 101, 195, 250),
                              ),
                              child: const Text(
                                "인증번호 발급",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(5),
                      if (openAuthCode && !closeAuthCode)
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
                                  onChanged: (value) {
                                    setState(() {
                                      verificationCode = value;
                                    });
                                  },
                                )),
                                Text(
                                  "${(remainingTime ~/ 60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}", // 분:초 형태로 표시
                                  style: const TextStyle(
                                    color: Colors.red, // 타이머 색상
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Gap(15),
                                SizedBox(
                                    width: 30,
                                    height: 20,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        verifyCode();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          side: const BorderSide(
                                            color: Colors.transparent,
                                            width: 1.0,
                                          ),
                                        ),
                                        padding: EdgeInsets.zero,
                                        elevation: 0,
                                        backgroundColor: const Color.fromARGB(
                                            255, 101, 195, 250),
                                      ),
                                      child: const Text(
                                        "인증",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.black,
                                        ),
                                      ),
                                    )),
                              ],
                            )),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 101, 195, 250),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate() &&
                        isVerify &&
                        isCheckId &&
                        isCheckNickname) {
                      formKey.currentState!.save();
                      postJoin();
                    } else if (!formKey.currentState!.validate()) {
                      showMyDialog(context, "유효성 검사 에러", "입력한 정보를 확인해주세요.");
                    } else if (!isCheckId || !isCheckNickname) {
                      showMyDialog(
                          context, "중복 확인 미실시", "아이디, 닉네임 중복확인을 해주세요.");
                    } else if (!isVerify) {
                      showMyDialog(
                          context, "전화번호 인증 에러", "전화번호 인증이 완료되지 않았습니다.");
                    }
                  },
                  child: const Text(
                    "회원가입",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              )
            ],
          ),
        )));
  }
}
