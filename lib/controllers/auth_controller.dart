import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
          synchronizable: true,
          accessibility: KeychainAccessibility.first_unlock));
  var isLoggedIn = false.obs;
  var accessToken = RxnString();
  var refreshToken = RxnString();
  var nickname = RxnString();
  var profileImage = RxnString();

  Future<void> login(String access, String refresh) async {
    // login_api에서 받은 토큰 값을 저장소에 저장
    await _storage.write(key: 'accessToken', value: access);
    await _storage.write(key: 'refreshToken', value: refresh);

    // 저장 후 확인용 코드
    print("Access Token Saved: ${await _storage.read(key: 'accessToken')}");
    print("Refresh Token Saved: ${await _storage.read(key: 'refreshToken')}");

    // AuthController의 상태 변수 업데이트
    accessToken.value = access;
    refreshToken.value = refresh;
    isLoggedIn.value = true;

    // 토큰 저장 후 사용자 프로필 정보를 로드
    await fetchUserProfile();
    print("Username Saved: ${await _storage.read(key: 'nickname')}");
    print("Profile Image Saved: ${await _storage.read(key: 'profileImage')}");
  }

  Future<void> fetchUserProfile() async {
    final String apiAddress = dotenv.get('API_ADDRESS');
    final token = await _storage.read(key: 'accessToken');
    if (token == null) return;

    final url = Uri.parse('$apiAddress/api/users/profile/');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        nickname.value = data['nickname'];
        profileImage.value = data['profile_image'];

        // 프로필 정보 저장
        await _storage.write(key: 'nickname', value: data['nickname']);
        await _storage.write(key: 'profileImage', value: data['profile_image']);
      } else {
        print('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'accessToekn');
    await _storage.delete(key: 'refreshToken');

    accessToken.value = null;
    refreshToken.value = null;
    isLoggedIn.value = false;
  }

  Future<void> loadLoginInfo() async {
    accessToken.value = await _storage.read(key: 'accessToken');
    refreshToken.value = await _storage.read(key: 'refreshToken');
    isLoggedIn.value = accessToken.value != null && refreshToken.value != null;
    nickname.value = await _storage.read(key: 'nickname');
    profileImage.value = await _storage.read(key: 'profileImage');

    // 확인용  콘솔 출력
    print("Access Token Loaded: ${accessToken.value}");
    print("Refresh Token Loaded: ${refreshToken.value}");
    print("Is Logged In: ${isLoggedIn.value}");
    print("nickname: ${nickname.value}");
    print("profileImage: ${profileImage.value}");
  }

  Future<void> updateProfileImageInStorage(String newProfileImage) async {
    // Flutter Secure Storage에 새로운 프로필 이미지 저장
    await _storage.write(key: 'profileImage', value: newProfileImage);
    profileImage.value = newProfileImage;

    print("Updated Profile Image in Storage: $newProfileImage");
  }
}
