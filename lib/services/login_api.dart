import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../controllers/auth_controller.dart'; // for jsonEncode

class LoginApi {
  final String API_ADDRESS = dotenv.get('API_ADDRESS'); // 환경 변수 불러오기
  late Uri uri;

  Future<bool> login(String id, String password) async {
    uri = Uri.parse('$API_ADDRESS/api/users/auth/login/');

    // 요청 바디 데이터 (JSON 형식)
    Map<String, String> body = {
      'username': id,
      'password': password,
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
      // 로그인 성공 시 서버 응답을 파싱하여 토큰 저장
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final accessToken = data['access'];
      final refreshToken = data['refresh'];

      // AuthController에 토큰 저장
      final AuthController authController = Get.find<AuthController>();
      authController.login(accessToken, refreshToken);

      // print("Access Token: $accessToken");
      // print("Refresh Token: $refreshToken");
      return true;
    } else {
      // 실패 시 에러 출력
      print(
          "Failed to login: ${response.statusCode}, ${utf8.decode(response.bodyBytes)}");
      return false;
    }
  }
}
