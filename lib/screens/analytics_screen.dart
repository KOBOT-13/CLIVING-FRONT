import 'package:cliving_front/charts/line_chart.dart';
import 'package:cliving_front/charts/pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Widget> gridViewWidgets = [
    SizedBox(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: LineChart(mainData()),
    )),
    //PieChartSectionData()
    // const SizedBox(
    //   height: 100,
    //   width: 100,
    //   child: Column(children: [
    //     Center(
    //       child: Text(
    //         '이번달 클라이밍 시간',
    //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
    //       ),
    //     ),
    //     Text('12:33'),
    //   ]),
    // ),
    const SizedBox(
      height: 100,
      width: 100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '이번달 클라이밍',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            Text(
              '12:33',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),

    const PieChartWidget(dataType: 1),
    const PieChartWidget(dataType: 2),
    const SizedBox(
      height: 100,
      width: 100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '올해 클라이밍',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            Text(
              '121:33',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
    // const SizedBox(
    //   height: 100,
    //   width: 100,
    //   //color: Colors.blue,
    //   child: Center(),
    // ),
    // Container(
    //   height: 100,
    //   width: 100,
    //   color: Colors.blue,
    //   child: const Center(child: Text('4')),
    // ),
    // Container(
    //   height: 100,
    //   width: 100,
    //   color: Colors.blue,
    //   child: const Center(child: Text('5')),
    // ),
  ];

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
            Expanded(
              child: StaggeredGrid.count(
                crossAxisCount: 4,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                children: [
                  StaggeredGridTile.count(
                    crossAxisCellCount: 4,
                    mainAxisCellCount: 2,
                    child: gridViewWidgets[0],
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 2,
                    child: gridViewWidgets[1],
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 2,
                    child: gridViewWidgets[2],
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 2,
                    child: gridViewWidgets[3],
                  ),
                  StaggeredGridTile.count(
                    crossAxisCellCount: 2,
                    mainAxisCellCount: 2,
                    child: gridViewWidgets[4],
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
