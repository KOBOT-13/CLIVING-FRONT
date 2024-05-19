import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  List<Widget> gridViewWidgets = [
    Container(
      height: 100,
      width: 100,
      color: Colors.blue,
      child: const Center(child: Text('1')),
    ),
    Container(
      height: 100,
      width: 100,
      color: Colors.blue,
      child: const Center(child: Text('2')),
    ),
    Container(
      height: 100,
      width: 100,
      color: Colors.blue,
      child: const Center(child: Text('3')),
    ),
    Container(
      height: 100,
      width: 100,
      color: Colors.blue,
      child: const Center(child: Text('4')),
    ),
    Container(
      height: 100,
      width: 100,
      color: Colors.blue,
      child: const Center(child: Text('5')),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
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
