import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartWidget extends StatelessWidget {
  const LineChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(mainData());
  }
}

LineChartData mainData() {
  List<Color> gradientColors = [
    Colors.grey,
    Colors.blue,
  ];

  return LineChartData(
    lineTouchData: const LineTouchData(enabled: true),
    gridData: FlGridData(
      show: true,
      drawVerticalLine: true,
      horizontalInterval: 1,
      verticalInterval: 1,
      getDrawingHorizontalLine: (value) {
        return const FlLine(
          color: Colors.grey,
          strokeWidth: 1,
        );
      },
      getDrawingVerticalLine: (value) {
        return const FlLine(
          color: Colors.grey,
          strokeWidth: 1,
        );
      },
    ),
    titlesData: const FlTitlesData(
      show: true,
      leftTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      rightTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: bottomTitleWidgets,
        ),
      ),
    ),
    borderData: FlBorderData(
      show: true,
      border: Border.all(color: const Color(0xff37434d)),
    ),
    minX: 0,
    maxX: 11,
    minY: 0,
    maxY: 6,
    lineBarsData: [
      LineChartBarData(
        spots: const [
          FlSpot(0, 3),
          FlSpot(1, 3),
          FlSpot(2, 3),
          FlSpot(3, 3),
          FlSpot(4, 3),
          FlSpot(5, 3),
          FlSpot(6, 2),
          FlSpot(7, 5),
          FlSpot(8, 3),
          FlSpot(9, 4),
          FlSpot(10, 3),
          FlSpot(11, 4),
        ],
        isCurved: false,
        gradient: LinearGradient(colors: gradientColors),
        barWidth: 5,
        isStrokeCapRound: true,
        dotData: const FlDotData(
          show: true,
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ),
    ],
  );
}

Widget bottomTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );
  Widget text;
  switch (value.toInt()) {
    case 0:
      text = const Text('1', style: style);
      break;
    case 1:
      text = const Text('2', style: style);
      break;
    case 2:
      text = const Text('3', style: style);
      break;
    case 3:
      text = const Text('4', style: style);
      break;
    case 4:
      text = const Text('5', style: style);
      break;
    case 5:
      text = const Text('6', style: style);
      break;
    case 6:
      text = const Text('7', style: style);
      break;
    case 7:
      text = const Text('8', style: style);
      break;
    case 8:
      text = const Text('9', style: style);
      break;
    case 9:
      text = const Text('10', style: style);
      break;
    case 10:
      text = const Text('11', style: style);
      break;
    case 11:
      text = const Text('12', style: style);
      break;
    default:
      text = const Text('', style: style);
      break;
  }

  return SideTitleWidget(
    axisSide: meta.axisSide,
    child: text,
  );
}
