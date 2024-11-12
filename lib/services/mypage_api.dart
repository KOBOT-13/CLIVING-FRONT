import 'package:cliving_front/controllers/auth_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService {
  final AuthController authController = Get.find<AuthController>();
  final String API_ADDRESS = dotenv.get('API_ADDRESS');
  late Uri uri;

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    final accessToken = authController.accessToken.value;
    print("Authorization Header: Bearer $accessToken");

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    final url = Uri.parse('$API_ADDRESS/api/users/profile/');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      // 성공적으로 사용자 정보 가져옴
      return json.decode(response.body);
    } else {
      print("Failed to fetch profile: ${response.statusCode}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateNickname(String newNickname) async {
    //URL 설정
    final url = Uri.parse('$API_ADDRESS/api/users/profile/update/');
    final accessToken = authController.accessToken.value;
    print("Authorization Header: Bearer $accessToken");

    // headers 정의
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    // body 정의
    Map<String, String> body = {'nickname': newNickname};

    final response =
        await http.patch(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 200) {
      // 성공적으로 사용자 정보 가져옴
      return json.decode(response.body);
    } else {
      print("Failed to patch nickname: ${response.statusCode}");
      return null;
    }
  }

  // Future<Map<String, dynamic>?> updateProfileImage(
  //     String newProfileImage) async {
  //   //URL 설정
  //   final url = Uri.parse('$API_ADDRESS/api/users/profile/update/');
  //   final accessToken = authController.accessToken.value;
  //   print("Authorization Header: Bearer $accessToken");

  //   // headers 정의
  //   Map<String, String> headers = {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $accessToken',
  //   };

  //   // body 정의
  //   Map<String, String> body = {'profile_image': newProfileImage};

  //   final response =
  //       await http.patch(url, headers: headers, body: jsonEncode(body));

  //   if (response.statusCode == 200) {
  //     // 성공적으로 사용자 정보 가져옴
  //     return json.decode(response.body);
  //   } else {
  //     print("Failed to patch profileImage : ${response.statusCode}");
  //     return null;
  //   }
  // }
}
