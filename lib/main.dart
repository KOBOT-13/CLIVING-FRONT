import 'package:cliving_front/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'screens/entry_screen.dart';
import 'screens/main_screen.dart';
import 'screens/join_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('ko_KR', null);
  Get.put(AuthController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: 'Pretendard', scaffoldBackgroundColor: Colors.white),
      home: const EntryScreen(),
      routes: <String, WidgetBuilder>{
        '/join': (BuildContext context) => const JoinScreen(),
        '/main': (BuildContext context) => const MainScreen(),
      },
    );
  }
}
