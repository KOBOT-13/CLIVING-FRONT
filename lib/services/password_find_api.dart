import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordFindApi {
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

  Future<bool> SendVerify(String phoneNumber) async {
    final url = Uri.parse('$API_ADDRESS/api/users/send-verification-code/');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    Map<String, String> body = {
      'phone_number': phoneNumber,
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
}
