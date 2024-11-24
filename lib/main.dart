import 'package:cliving_front/controllers/auth_controller.dart';
import 'package:cliving_front/services/logout_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'screens/entry_screen.dart';
import 'screens/main_screen.dart';
import 'screens/join_screen.dart';
import 'screens/find_password_screen.dart';
import 'screens/change_password_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:device_preview/device_preview.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('ko_KR', null);
  Get.put(AuthController());
  LogoutApi().logout();
  final authController = Get.find<AuthController>();
  await authController.loadLoginInfo();
  runApp(DevicePreview(
      enabled: !kReleaseMode, builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      useInheritedMediaQuery: true, // DevicePreview를 위해 추가
      locale: DevicePreview.locale(context), // DevicePreview의 locale 사용
      builder: DevicePreview.appBuilder, // DevicePreview의 builder 사용
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'Pretendard', scaffoldBackgroundColor: Colors.white),
      home: const EntryScreen(),
      routes: <String, WidgetBuilder>{
        '/join': (BuildContext context) => const JoinScreen(),
        '/main': (BuildContext context) => const MainScreen(),
        '/find-password': (BuildContext context) => const FindPasswordScreen(),
        '/change-password': (BuildContext context) =>
            const ChangePasswordScreen(),
      },
    );
  }
}
