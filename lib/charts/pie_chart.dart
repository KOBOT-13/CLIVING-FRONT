import 'package:cliving_front/services/analytics_api.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatefulWidget {
  final int dataType;
  final String selectedYear;
  final String selectedMonth;

  const PieChartWidget(
      {super.key,
      required this.dataType,
      required this.selectedYear,
      required this.selectedMonth});

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

  // dataType이 변경될 때마다 다시 API 요청
  @override
  void didUpdateWidget(covariant PieChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dataType != widget.dataType ||
        oldWidget.selectedYear != widget.selectedYear ||
        oldWidget.selectedMonth != widget.selectedMonth) {
      setState(() {
        colorData =
            _getColorData(widget.dataType); // 변경된 dataType에 맞는 데이터 다시 가져오기
      });
    }
  }

  Future<List<dynamic>> _getColorData(int dataType) {
    if (dataType == 1) {
      // 월별 데이터를 가져옴
      return AnalyticsApi()
          .getMonthlyColor(widget.selectedYear, widget.selectedMonth);
    } else {
      // 연별 데이터를 가져옴
      return AnalyticsApi().getAnnualColor(widget.selectedYear);
    }
  }

  List<PieChartSectionData> generateEmptyChartData() {
    // 데이터가 없을 경우 빈 원형 그래프 섹션 생성
    return [
      PieChartSectionData(
        color: Colors.grey[300],
        value: 1,
        title: '',
        radius: 70,
      ),
    ];
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
                // 데이터가 없을 경우
                return Center(
                  child: PieChart(
                    PieChartData(
                      sections: generateEmptyChartData(),
                      centerSpaceRadius: 0,
                    ),
                  ),
                );
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
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'navy':
        return const Color.fromRGBO(0, 0, 55, 1);
      case 'red':
        return Colors.red;
      case 'pink':
        return const Color.fromARGB(255, 253, 125, 168);
      case 'purple':
        return Colors.purple;
      case 'grey':
        return Colors.grey;
      case 'brown':
        return Colors.brown;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      default:
        return Colors.black; // 기본 값으로 'black'을 반환
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
