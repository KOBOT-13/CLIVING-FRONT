import 'package:flutter/material.dart';

Future<void> showMyDialog(
    BuildContext context, String title, String content) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                content,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              '확인',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Pretendard',
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 101, 195, 250),
      );
    },
  );
}
