import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../controllers/auth_controller.dart';

class DeleteAccountApi {
  final AuthController authController = Get.find<AuthController>();
  final String API_ADDRESS = dotenv.get('API_ADDRESS'); // 환경 변수 불러오기
  late Uri uri;

  Future<bool> deleteAccount() async {
    uri = Uri.parse('$API_ADDRESS/api/users/delete-account/');
    final accessToken = authController.accessToken.value;

    // 헤더 설정
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    // HTTP DELETE 요청
    final response = await http.delete(
      uri,
      headers: headers,
    );

    // 응답 처리
    if (response.statusCode == 200) {
      // AuthController에서 토큰 삭제 및 로그아웃 처리
      await authController.logout();
      print("Account successfully deleted and tokens cleared.");
      return true;
    } else {
      // 실패 시 에러 출력
      print(
          "Failed to delete account: ${response.statusCode}, ${utf8.decode(response.bodyBytes)}");
      return false;
    }
  }
}
