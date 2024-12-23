import 'package:cliving_front/controllers/auth_controller.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class UserService {
  final AuthController authController = Get.find<AuthController>();
  final String API_ADDRESS = dotenv.get('API_ADDRESS');

  Future<Map<String, dynamic>?> updateNickname(String newNickname) async {
    //URL 설정
    final url = Uri.parse('$API_ADDRESS/api/users/profile/');
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
      // Flutter Secure Storage에 새로운 닉네임 저장
      await authController.updateNicknameInStorage(newNickname);

      return json.decode(response.body);
    } else {
      print("Failed to patch nickname: ${response.statusCode}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateProfileImage(
      XFile newProfile, String accessToken) async {
    //URL 설정
    final url = '$API_ADDRESS/api/users/profile/';
    print("Authorization Header: Bearer $accessToken");

    dio.Dio dioClient = dio.Dio();
    try {
      dio.FormData formData = dio.FormData.fromMap({
        'profile_image': await dio.MultipartFile.fromFile(
          newProfile.path,
          filename: 'profile.jpg',
        )
      });
      print('formData: ${newProfile.path}');
      print('accessToken: $accessToken');

      // 요청 보내기
      dio.Response response = await dioClient.patch(
        url,
        data: formData,
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // 응답 처리
      if (response.statusCode == 200) {
        print("프로필 이미지 업로드 성공");
        // 서버 응답에서 프로필 이미지 URL 가져오기
        final newProfileImage = response.data['profile_image'];
        if (newProfileImage != null) {
          // Flutter Secure Storage에 프로필 이미지 업데이트
          await authController.updateProfileImageInStorage(newProfileImage);
        }

        return response.data;
      } else {
        print("업로드 실패: ${response.statusCode}");
        print("서버 응답: ${response.data}");
        return null;
      }
    } catch (e) {
      print("업로드 중 오류 발생: $e");
      return null;
    }
  }

  Future<bool> changePassword(
      String currentPassword, String newPassword1, String newPassword2) async {
    // URL 설정
    final url = Uri.parse('$API_ADDRESS/api/users/change-password/');
    final accessToken = authController.accessToken.value;

    // headers 정의
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };

    // body 정의
    Map<String, String> body = {
      'current_password': currentPassword,
      'new_password1': newPassword1,
      'new_password2': newPassword2,
    };

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
