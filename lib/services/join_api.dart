import 'dart:ffi';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert'; // for jsonEncode

class JoinApi {
  final String API_ADDRESS = dotenv.get('API_ADDRESS'); // 환경 변수 불러오기
  late Uri uri;

  // postJoin 메서드 - 아이디, 비밀번호, 닉네임 등을 파라미터로 받음
  Future<void> postJoin(String username, String password1, String password2,
      String nickname, String phoneNumber) async {
    // 서버로 요청할 URL 설정
    uri = Uri.parse('$API_ADDRESS/api/users/auth/registration/');

    // 요청 바디 데이터 (JSON 형식)
    Map<String, String> body = {
      'username': username,
      'nickname': nickname,
      'password1': password1,
      'password2': password2,
      'phone_number': phoneNumber,
    };

    // 헤더 설정
    Map<String, String> headers = {
      'Content-Type': 'application/json', // JSON 데이터를 보내기 위해 Content-Type 설정
    };

    // HTTP POST 요청
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body), // body를 JSON 형식으로 변환
    );

    // 응답 처리
    if (response.statusCode == 201) {
      // 성공 시 응답 바디 출력
      print("Response: ${response.body}");
    } else {
      // 실패 시 에러 출력
      print(
          "Failed to register: ${response.statusCode}, ${utf8.decode(response.bodyBytes)}");
    }
  }

  Future<bool> verificationCode(String phoneNumber) async {
    // 서버로 요청할 URL 설정
    uri = Uri.parse('$API_ADDRESS/api/users/send-verification-code/');

    // 요청 바디 데이터 (JSON 형식)
    Map<String, String> body = {'phone_number': phoneNumber};

    // 헤더 설정
    Map<String, String> headers = {
      'Content-Type': 'application/json', // JSON 데이터를 보내기 위해 Content-Type 설정
    };

    // HTTP POST 요청
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body), // body를 JSON 형식으로 변환
    );

    // 응답 처리
    if (response.statusCode == 200) {
      // 성공 시 응답 바디 출력
      print("Response: ${utf8.decode(response.bodyBytes)}");
      return true;
    } else {
      // 실패 시 에러 출력
      print(
          "Failed to send code: ${response.statusCode}, ${utf8.decode(response.bodyBytes)}");
      return false;
    }
  }

  Future<bool> verifyPhoneCode(
      String verificationCode, String phoneNumber) async {
    // 서버로 요청할 URL 설정
    uri = Uri.parse('$API_ADDRESS/api/users/verify-phone-code/');

    // 요청 바디 데이터 (JSON 형식)
    Map<String, String> body = {
      'phone_number': phoneNumber,
      'verification_code': verificationCode
    };

    // 헤더 설정
    Map<String, String> headers = {
      'Content-Type': 'application/json', // JSON 데이터를 보내기 위해 Content-Type 설정
    };

    // HTTP POST 요청
    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body), // body를 JSON 형식으로 변환
    );

    // 응답 처리
    if (response.statusCode == 200) {
      // 성공 시 응답 바디 출력
      print("Response: ${utf8.decode(response.bodyBytes)}");
      return true;
    } else {
      // 실패 시 에러 출력
      print(
          "Failed to verify: ${response.statusCode}, ${utf8.decode(response.bodyBytes)}");
      return false;
    }
  }
}
