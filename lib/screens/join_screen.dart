import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

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
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Row의 높이를 맞추기 위해 사용
                      children: [
                        Expanded(
                          child: TextFormField(
                            cursorColor: Colors.black,
                            decoration: const InputDecoration(
                              hintText: '아이디',
                              labelStyle: TextStyle(color: Colors.black),
                              contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                ),
                              ),
                            ),
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
                        const SizedBox(width: 10), // Row 내에서 버튼과 필드 사이의 간격 추가
                        SizedBox(
                          width: 70,
                          height: 40, // TextFormField와 동일한 높이
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
                    const SizedBox(height: 10), // 에러 메시지 및 공간 확보
                    TextFormField(
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                        hintText: '비밀번호',
                        hintStyle: TextStyle(color: Colors.black),
                        contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.black,
                        )),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
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
                    const SizedBox(height: 10), // 에러 메시지 및 공간 확보
                    TextFormField(
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                        hintText: '비밀번호 확인',
                        hintStyle: TextStyle(color: Colors.black),
                        contentPadding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.black,
                        )),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
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
