import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  Widget CustomProfileField(String labelText, String placeholder,
      bool DuplicateCheck, bool maxLength, bool isNumber) {
    return Container(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding: const EdgeInsets.only(left: 5),
              child: Text(
                labelText,
                style: const TextStyle(fontSize: 15),
              )),
          const SizedBox(
            height: 5,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Row의 높이를 맞추기 위해 사용
            children: [
              Expanded(
                child: TextFormField(
                  maxLength: maxLength ? 15 : null,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: placeholder,
                    // labelText: labelText,
                    labelStyle: const TextStyle(color: Colors.black),
                    contentPadding: const EdgeInsets.only(left: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.black,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
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
                  onSaved: (value) {
                    // id = value!;
                  },
                  keyboardType: isNumber ? TextInputType.number : null,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    NumberFormatter(),
                    LengthLimitingTextInputFormatter(13)
                  ],
                ),
              ),
              if (DuplicateCheck) ...{
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 60,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      print("중복확인");
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      backgroundColor: const Color.fromARGB(255, 101, 195, 250),
                    ),
                    child: const Text(
                      "중복 확인",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                )
              }
            ],
          ),
        ],
      ),
    );
  }
}
