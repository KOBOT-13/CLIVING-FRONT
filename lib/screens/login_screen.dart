import 'package:cliving_front/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/login_api.dart';
import '../widgets/custom_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginApi api = LoginApi();
  final AuthController authController = Get.find<AuthController>();

  late String id;
  late String password;

  void login() async {
    bool check = await api.login(id, password);
    if (check) {
      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
    } else {
      showMyDialog(context, "로그인 실패", "로그인을 실패하였습니다. 아이디와 비밀번호를 확인해주세요.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Center(
                child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: deviceHeight / 5),
                  child: Image.asset(
                    'assets/images/entry.png',
                    width: deviceWidth / 1.5,
                    height: deviceWidth / 1.5,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                  child: TextField(
                      onChanged: (value) {
                        setState(() {
                          id = value;
                        });
                      },
                      decoration: const InputDecoration(
                          hintText: '아이디',
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Colors.black,
                          )),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromRGBO(46, 149, 210, 1),
                            width: 2.0,
                          )))),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                    obscureText: true,
                    decoration: const InputDecoration(
                        hintText: '비밀번호',
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Colors.black,
                        )),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Color.fromRGBO(46, 149, 210, 1),
                          width: 2.0,
                        ))),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: ElevatedButton(
                    onPressed: () {
                      login();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(46, 149, 210, 1),
                        minimumSize: Size(deviceWidth, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )),
                    child: const Text(
                      "로그인",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/join');
                            },
                            child: const Text(
                              "회원가입",
                              style: TextStyle(
                                color: Color(0xFF1B1B1B),
                              ),
                            )),
                      ),
                      const Text(
                        " | ",
                        style: TextStyle(color: Color(0xFFC8AAAA)),
                      ),
                      Expanded(
                        child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/find-password');
                            },
                            child: const Text(
                              "비밀번호 찾기",
                              style: TextStyle(
                                color: Color(0xFF1B1B1B),
                              ),
                            )),
                      ),
                    ],
                  ),
                )
              ],
            )),
          ),
        ));
  }
}
