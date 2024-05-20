import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartWidget extends StatefulWidget {
  final int dataType;

  const PieChartWidget({super.key, required this.dataType});

  @override
  State<StatefulWidget> createState() => PieChartWidgetState();
}

class PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: PieChart(
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
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              startDegreeOffset: 180,
              borderData: FlBorderData(
                show: false,
              ),
              sectionsSpace: 2,
              centerSpaceRadius: 0,
              sections: generatePieChartData(widget.dataType),
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> generatePieChartData(int dataType) {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 80.0 : 70.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (dataType) {
        case 1:
          return _getSectionData(
              i, fontSize, radius, shadows, [40, 30, 20, 10]);
        case 2:
          return _getSectionData(
              i, fontSize, radius, shadows, [50, 25, 15, 10]);
        default:
          return _getSectionData(
              i, fontSize, radius, shadows, [25, 25, 25, 25]);
      }
    });
  }

  PieChartSectionData _getSectionData(int i, double fontSize, double radius,
      List<Shadow> shadows, List<double> values) {
    switch (i) {
      case 0:
        return PieChartSectionData(
          color: AppColors.contentColorBlue,
          value: values[0],
          title: '',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.mainTextColor1,
            shadows: shadows,
          ),
        );
      case 1:
        return PieChartSectionData(
          color: AppColors.contentColorYellow,
          value: values[1],
          title: '',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.mainTextColor1,
            shadows: shadows,
          ),
        );
      case 2:
        return PieChartSectionData(
          color: AppColors.contentColorPurple,
          value: values[2],
          title: '',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.mainTextColor1,
            shadows: shadows,
          ),
        );
      case 3:
        return PieChartSectionData(
          color: AppColors.contentColorGreen,
          value: values[3],
          title: '',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.mainTextColor1,
            shadows: shadows,
          ),
        );
      default:
        throw Error();
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



// List<PieChartSectionData> generatePieChartData(int dataType) {
//   // Generate different data based on dataType
//   switch (dataType) {
//     case 1:
//       return [
//         PieChartSectionData(
//           color: AppColors.contentColorBlue,
//           value: 40,
//           title: '40%',
//           radius: 80,
//         ),
//         PieChartSectionData(
//           color: AppColors.contentColorYellow,
//           value: 30,
//           title: '30%',
//           radius: 70,
//         ),
//         PieChartSectionData(
//           color: AppColors.contentColorPink,
//           value: 20,
//           title: '20%',
//           radius: 60,
//         ),
//         PieChartSectionData(
//           color: AppColors.contentColorGreen,
//           value: 10,
//           title: '10%',
//           radius: 50,
//         ),
//       ];
//     case 2:
//       return [
//         PieChartSectionData(
//           color: AppColors.contentColorOrange,
//           value: 50,
//           title: '50%',
//           radius: 90,
//         ),
//         PieChartSectionData(
//           color: AppColors.contentColorPurple,
//           value: 25,
//           title: '25%',
//           radius: 80,
//         ),
//         PieChartSectionData(
//           color: AppColors.contentColorRed,
//           value: 15,
//           title: '15%',
//           radius: 70,
//         ),
//         PieChartSectionData(
//           color: AppColors.contentColorCyan,
//           value: 10,
//           title: '10%',
//           radius: 60,
//         ),
//       ];
//     default:
//       return [
//         PieChartSectionData(
//           color: AppColors.contentColorBlue,
//           value: 25,
//           title: '25%',
//           radius: 80,
//         ),
//         PieChartSectionData(
//           color: AppColors.contentColorYellow,
//           value: 25,
//           title: '25%',
//           radius: 70,
//         ),
//         PieChartSectionData(
//           color: AppColors.contentColorPink,
//           value: 25,
//           title: '25%',
//           radius: 60,
//         ),
//         PieChartSectionData(
//           color: AppColors.contentColorGreen,
//           value: 25,
//           title: '25%',
//           radius: 50,
//         ),
//       ];
//   }
// }
