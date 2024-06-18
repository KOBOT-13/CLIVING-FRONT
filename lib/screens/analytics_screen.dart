import 'dart:convert';

import 'package:cliving_front/charts/line_chart.dart';
import 'package:cliving_front/charts/pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late Future<String> annualTime;
  late Future<String> monthlyTime;
  late Future<String> specificMonthlyTime;

  @override
  void initState() {
    super.initState();
    annualTime = _getAnnualTime();
    monthlyTime = _getMonthlyTime();
    specificMonthlyTime = _getSpecificMonthlyTime();
  }

  Future<String> _getMonthlyTime() async {
    String apiAddress = dotenv.get("API_ADDRESS");
    final url = Uri.parse('$apiAddress/v1/statistics/monthly/climbing-time/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> readMonthlyTime =
          json.decode(utf8.decode(response.bodyBytes));
      print(readMonthlyTime);
      return readMonthlyTime['total_climbing_time_hhmm'];
    } else {
      throw Exception('Failed to read Monthly Time.');
    }
  }

  Future<String> _getAnnualTime() async {
    String apiAddress = dotenv.get("API_ADDRESS");
    final url = Uri.parse('$apiAddress/v1/statistics/annual/climbing-time/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
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

  Future<String> _getSpecificMonthlyTime() async {
    String apiAddress = dotenv.get("API_ADDRESS");
    int year = 2024;
    int month = 3;
    final url =
        Uri.parse('$apiAddress/v1/statistics/climbing-time/$year/$month');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.ideographic,
              children: [
                Text(
                  '혜진', // 여기에 원하는 이름을 넣어주세요.
                  style: TextStyle(
                    fontSize: 40, // 이름을 크게 표시할 폰트 크기입니다.
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '님의 클라이밍은요', // 나머지 부분은 여기에 작성하세요.
                  style: TextStyle(
                    fontSize: 25, // 나머지 부분의 폰트 크기입니다.
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: StaggeredGrid.count(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: [
                  const StaggeredGridTile.count(
                    crossAxisCellCount: 4,
                    mainAxisCellCount: 2,
                    child: SizedBox(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: LineChartWidget(),
                      ),
                    ),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 2,
                    child: FutureBuilder<String>(
                      future: monthlyTime,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text('Error loading data'));
                        } else {
                          return SizedBox(
                            height: 100,
                            width: 100,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    '이번달 클라이밍',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    snapshot.data ?? 'N/A',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 35,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 2,
                    child: PieChartWidget(dataType: 1),
                  ),
                  const StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 2,
                    child: PieChartWidget(dataType: 2),
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 2,
                    child: FutureBuilder<String>(
                      future: annualTime,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text('Error loading data'));
                        } else {
                          return SizedBox(
                            height: 100,
                            width: 100,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    '올해 클라이밍',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    snapshot.data ?? 'N/A',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 35,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
