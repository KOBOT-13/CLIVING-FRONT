import 'package:flutter/material.dart';

class FindPasswordScreen extends StatefulWidget {
  const FindPasswordScreen({super.key});

  @override
  State<FindPasswordScreen> createState() => _FindPasswordScreenState();
}

class _FindPasswordScreenState extends State<FindPasswordScreen> {
  final _idController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
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
          child: Column(
            children: [
              const Text("아이디와 전화번호를 입력해 주세요."),
              TextField(
                controller: _idController,
                decoration: const InputDecoration(
                    labelText: '아이디',
                    floatingLabelStyle: TextStyle(color: Colors.blue),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1),
                    )),
                obscureText: true,
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _newPassword2Controller,
                decoration: InputDecoration(
                  labelText: '새로운 비밀번호 재입력',
                  floatingLabelStyle: const TextStyle(color: Colors.blue),
                  border: const OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1),
                  ),
                  errorText: isPasswordMatch ? null : '비밀번호가 일치하지 않습니다.',
                ),
                obscureText: true,
                onChanged: (value) => passwordMatch(),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () {
                  handlePasswordChange();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(50, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                child: const Text(
                  "비밀번호 변경",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
