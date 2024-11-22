import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import '../controllers/auth_controller.dart';

class AnalyticsApi {
  final AuthController authController = Get.find<AuthController>();
  final String API_ADDRESS = dotenv.get('API_ADDRESS');
  late Uri uri;
  String apiAddress = dotenv.get("API_ADDRESS");

  Future<String> getMonthlyTime(
      String selectedYear, String selectedMonth) async {
    final accessToken = authController.accessToken.value;
    final url = Uri.parse(
        '$apiAddress/v1/statistics/climbing-time/$selectedYear/$selectedMonth/');

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
      return readMonthlyTime['total_climbing_time_hhmm'];
    } else {
      throw Exception('Failed to read Monthly Time.');
    }
  }

  Future<String> getAnnualTime(String selectedYear) async {
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

      return readAnnualTime['total_climbing_time_hhmm'];
    } else {
      throw Exception('Failed to read Annual Time.');
    }
  }

  Future<List<dynamic>> getMonthlyColor(
      String selectedYear, String selectedMonth) async {
    final accessToken = authController.accessToken.value;
    final url = Uri.parse(
        '$apiAddress/v1/statistics/color-tries/$selectedYear/$selectedMonth/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> readMonthlyColor =
          json.decode(utf8.decode(response.bodyBytes));
      return readMonthlyColor;
    } else {
      throw Exception('Failed to read Monthly Color.');
    }
  }

  Future<List<dynamic>> getAnnualColor(String selectedYear) async {
    final accessToken = authController.accessToken.value;
    final url =
        Uri.parse('$apiAddress/v1/statistics/color-tries/$selectedYear/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> readAnnualColor =
          json.decode(utf8.decode(response.bodyBytes));
      return readAnnualColor;
    } else {
      throw Exception('Failed to read Annual Color.');
    }
  }
}
