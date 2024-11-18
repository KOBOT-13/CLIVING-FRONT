import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import '../controllers/auth_controller.dart'; // for jsonEncode

class AnalyticsApi {
  final AuthController authController = Get.find<AuthController>();
  final String API_ADDRESS = dotenv.get('API_ADDRESS');
  late Uri uri;

  Future<String> getMonthlyTime(
      String selectedYear, String selectedMonth) async {
    String apiAddress = dotenv.get("API_ADDRESS");
    final accessToken = authController.accessToken.value;
    final url = Uri.parse(
        '$apiAddress/v1/statistics/climbing-time/$selectedYear/$selectedMonth');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> readMonthlyTime =
          json.decode(utf8.decode(response.bodyBytes));
      print(readMonthlyTime);
      print(selectedMonth);
      print(readMonthlyTime['total_climbing_time_hhmm']);
      return readMonthlyTime['total_climbing_time_hhmm'];
    } else {
      throw Exception('Failed to read Monthly Time.');
    }
  }

  Future<String> getAnnualTime(String selectedYear) async {
    String apiAddress = dotenv.get("API_ADDRESS");
    final accessToken = authController.accessToken.value;
    final url =
        Uri.parse('$apiAddress/v1/statistics/climbing-time/$selectedYear/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> readAnnualTime =
          json.decode(utf8.decode(response.bodyBytes));

      print(readAnnualTime['total_climbing_time_hhmm']);
      return readAnnualTime['total_climbing_time_hhmm'];
    } else {
      throw Exception('Failed to read Annual Time.');
    }
  }
}
