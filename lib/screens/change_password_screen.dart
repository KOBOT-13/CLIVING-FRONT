import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import '../services/password_find_api.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  PasswordFindApi pf = PasswordFindApi();
  final _newPassword1Controller = TextEditingController();
  final _newPassword2Controller = TextEditingController();
  final passwordPattern =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$');
  bool isPasswordValid = true; // 비밀번호 유효성 검사
  bool isPasswordMatch = true; // 비밀번호 재입력 검사

  @override
  void dispose() {
    _newPassword1Controller.dispose();
    _newPassword2Controller.dispose();
    super.dispose();
  }

  void passwordValidate() {
    setState(() {
      isPasswordValid =
          passwordPattern.hasMatch(_newPassword1Controller.text); // 정규식 확인
    });
  }

  void passwordMatch() {
    setState(() {
      isPasswordMatch = _newPassword1Controller.text ==
          _newPassword2Controller.text; // 일치 여부 확인
    });
  }

  Future<void> handlePasswordChange() async {
    // 입력 유효성 검증
    if (!isPasswordValid || !isPasswordMatch) {
      Get.snackbar(
        "비밀번호 변경 실패",
        "비밀번호 조건을 확인해주세요.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    // 비밀번호 변경 API 호출
    final success = await pf.changePassword(
      _newPassword1Controller.text,
      _newPassword2Controller.text,
    );
    if (success) {
      // 성공 시 스낵바 메시지 표시 및 마이페이지로 이동
      if (context.mounted) {
        Get.snackbar(
          "비밀번호 변경 성공",
          "비밀번호가 성공적으로 변경되었습니다.",
          snackPosition: SnackPosition.BOTTOM,
        );
        Navigator.pop(context); // 이전 화면(마이페이지)으로 이동
      }
    } else {
      // 실패 시 오류 메시지 표시
      Get.snackbar(
        "비밀번호 변경 실패",
        "현재 비밀번호가 일치하지 않습니다.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          '비밀번호 변경',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Gap(30),
                const Text("변경할 새로운 비밀번호를 입력하세요."),
                const Gap(10),
                TextFormField(
                  controller: _newPassword1Controller,
                  decoration: InputDecoration(
                      labelText: '새로운 비밀번호',
                      floatingLabelStyle: const TextStyle(color: Colors.blue),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 1),
                      ),
                      errorText: isPasswordValid
                          ? null
                          : '비밀번호는 8자 이상, 영어 + 숫자 + 특수기호를 포함해야 합니다.'),
                  obscureText: true,
                  onChanged: (value) => passwordValidate(),
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
      ),
    );
  }
}
