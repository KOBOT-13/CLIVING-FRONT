import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordChangeApi {
  final String API_ADDRESS = dotenv.get("API_ADDRESS");

  Future<bool> VerifyUser(String username, String phoneNumber) async {
    final url = Uri.parse('$API_ADDRESS/api/users/verify-user/');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    Map<String, String> body = {
      'username': username,
      'phone_number': phoneNumber,
    };

    try {
      final response =
          await http.post(url, headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
        return true;
      } else {
        print(response.statusCode);
        print(utf8.decode(response.bodyBytes));
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> CheckVerify(String phoneNumber, String verificationCode) async {
    final url = Uri.parse('$API_ADDRESS/api/users/verify-phone-code/');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    Map<String, String> body = {
      'phone_number': phoneNumber,
      'verification_code': verificationCode,
    };

    try {
      final response =
          await http.post(url, headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
        print('인증성공');
        return true;
      } else {
        print(response.statusCode);
        print(utf8.decode(response.bodyBytes));
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> changePassword(
      String username, String newPassword1, String newPassword2) async {
    // URL 설정
    final url = Uri.parse('$API_ADDRESS/api/users/reset-password/');
    print(username);
    // headers 정의
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    // body 정의
    Map<String, String> body = {
      'username': username,
      'password1': newPassword1,
      'password2': newPassword2,
    };
    print(body);

    try {
      final response =
          await http.post(url, headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
        print("비밀번호 변경 성공");
        return true;
      } else {
        print("비밀번호 변경 실패: ${utf8.decode(response.bodyBytes)}");
        print("서버 응답: ${utf8.decode(response.bodyBytes)}");
        return false;
      }
    } catch (e) {
      print("비밀번호 변경 중 오류 발생: $e");
      return false;
    }
  }
}
