import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

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
  final formKey = GlobalKey<FormState>();
  late String id;
  late String password;
  late String password2;

  bool isIdValid = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        body: Stack(
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
                          // height: 5,
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
                              counterText: '',
                              labelStyle: const TextStyle(color: Colors.black),
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
                            onSaved: (value) {
                              id = value!;
                            },
                          ),
                        ),
                        const Gap(10),
                        SizedBox(
                          width: 60,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              print("중복확인");
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
                    const Gap(30),
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
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return '비밀번호를 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                    const Gap(30), // 에러 메시지 및 공간 확보
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
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return '비밀번호 확인을 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                    const Gap(30), // 에러 메시지 및 공간 확보
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
                              labelStyle: const TextStyle(color: Colors.black),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(10, 5, 10, 5),
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
                            onSaved: (value) {
                              id = value!;
                            },
                          ),
                        ),
                        const SizedBox(width: 10), // Row 내에서 버튼과 필드 사이의 간격 추가
                        SizedBox(
                          width: 60,
                          height: 50, // TextFormField와 동일한 높이
                          child: ElevatedButton(
                            onPressed: () {
                              print("중복확인");
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
                    const Gap(30), // 에러 메시지 및 공간 확보
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
                              labelStyle: const TextStyle(color: Colors.black),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(10, 5, 10, 5),
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
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return '전화번호를 입력해주세요.'; // 에러 메시지
                              }
                              return null;
                            },
                            onSaved: (value) {
                              id = value!;
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
                            onPressed: () {
                              print("중복확인");
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
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    print('유효성 검사 통과');
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
        ));
  }
}
