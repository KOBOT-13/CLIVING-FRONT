import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PieChartWidget extends StatefulWidget {
  final int dataType;

  const PieChartWidget({super.key, required this.dataType});

  @override
  State<StatefulWidget> createState() => PieChartWidgetState();
}

class PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;
  late Future<List<dynamic>> colorData;

  @override
  void initState() {
    super.initState();
    colorData = _getColorData(widget.dataType);
  }

  Future<List<dynamic>> _getColorData(int dataType) {
    if (dataType == 1) {
      return _getMonthlyColor();
    } else {
      return _getAnnualColor();
    }
  }

  Future<List<dynamic>> _getMonthlyColor() async {
    String apiAddress = dotenv.get("API_ADDRESS");
    final url = Uri.parse('$apiAddress/v1/statistics/monthly/color-tries/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
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

  Future<List<dynamic>> _getAnnualColor() async {
    String apiAddress = dotenv.get("API_ADDRESS");
    final url = Uri.parse('$apiAddress/v1/statistics/annual/color-tries/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: colorData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Error loading data'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No data available'));
              } else {
                return PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    startDegreeOffset: 180,
                    borderData: FlBorderData(
                      show: false,
                    ),
                    sectionsSpace: 2,
                    centerSpaceRadius: 0,
                    sections: generatePieChartData(snapshot.data!),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> generatePieChartData(List<dynamic> data) {
    List<PieChartSectionData> sections = [];
    for (int i = 0; i < data.length; i++) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 80.0 : 70.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      sections.add(
        PieChartSectionData(
          color: _getColorFromName(data[i]['color']),
          value: data[i]['tries'].toDouble(),
          title: data[i]['tries'].toString(),
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.mainTextColor1,
            shadows: shadows,
          ),
        ),
      );
    }
    return sections;
  }

  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      // Add more colors as needed
      default:
        return Colors.grey;
    }
  }
}

class AppColors {
  static const Color primary = contentColorCyan;
  static const Color menuBackground = Color(0xFF090912);
  static const Color itemsBackground = Color(0xFF1B2339);
  static const Color pageBackground = Color(0xFF282E45);
  static const Color mainTextColor1 = Colors.white;
  static const Color mainTextColor2 = Colors.white70;
  static const Color mainTextColor3 = Colors.white38;
  static const Color mainGridLineColor = Colors.white10;
  static const Color borderColor = Colors.white54;
  static const Color gridLinesColor = Color(0x11FFFFFF);

  static const Color contentColorBlack = Colors.black;
  static const Color contentColorWhite = Colors.white;
  static const Color contentColorBlue = Color(0xFF2196F3);
  static const Color contentColorYellow = Color(0xFFFFC300);
  static const Color contentColorOrange = Color(0xFFFF683B);
  static const Color contentColorGreen = Color(0xFF3BFF49);
  static const Color contentColorPurple = Color(0xFF6E1BFF);
  static const Color contentColorPink = Color(0xFFFF3AF2);
  static const Color contentColorRed = Color(0xFFE80054);
  static const Color contentColorCyan = Color(0xFF50E4FF);
}
