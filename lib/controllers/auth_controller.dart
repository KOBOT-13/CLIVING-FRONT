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
    await _storage.write(key: 'accessToken', value: access);
    await _storage.write(key: 'refreshToken', value: refresh);

    accessToken.value = access;
    refreshToken.value = refresh;
    isLoggedIn.value = true;

    // // 확인용 콘솔 출력
    // print("Access Token Saved: $access");
    // print("Refresh Token Saved: $refresh");
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

    // // 확인용  콘솔 출력
    // print("Access Token Loaded: ${accessToken.value}");
    // print("Refresh Token Loaded: ${refreshToken.value}");
    // print("Is Logged In: ${isLoggedIn.value}");
  }
}
