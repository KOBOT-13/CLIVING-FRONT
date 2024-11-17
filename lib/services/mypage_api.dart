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
  late Uri uri;

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

  Future<Map<String, dynamic>?> updateProfileImage(
      XFile newProfile, String accessToken) async {
    //URL 설정
    final url = '$API_ADDRESS/api/users/profile/';
    print("Authorization Header: Bearer $accessToken");

    dio.Dio dioClient = dio.Dio();
    final authController = Get.find<AuthController>();
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
            // 'Content-Type': 'multipart/form-data',
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
}
