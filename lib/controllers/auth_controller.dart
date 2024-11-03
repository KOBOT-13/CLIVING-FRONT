import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
          synchronizable: true,
          accessibility: KeychainAccessibility.first_unlock));
  var isLoggedIn = false.obs;
  var accessToken = RxnString();
  var refreshToken = RxnString();

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

    // 확인용  콘솔 출력
    print("Access Token Loaded: ${accessToken.value}");
    print("Refresh Token Loaded: ${refreshToken.value}");
    print("Is Logged In: ${isLoggedIn.value}");
  }
}
