import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: deviceHeight/5),
              child: Image.asset(
                'assets/images/entry.png',
                width: 250,
                height: 250,
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 40, 20, 0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '아이디',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    )
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(46, 149, 210, 1),
                      width: 2.0,
                    )
                  )
                )
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '비밀번호',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black,
                    )
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromRGBO(46, 149, 210, 1),
                      width: 2.0,
                    )
                  )
                )
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: ElevatedButton(
                onPressed: () {
                  print("로그인 실행");
                }, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(46, 149, 210, 1),
                  minimumSize: Size(deviceWidth, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )
                ),
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
              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                        onPressed: () {
                          // Navigator.pushNamed(context, '');
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
                          // Navigator.pushNamed(context, '');
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
        )
      )
    );
  }
}