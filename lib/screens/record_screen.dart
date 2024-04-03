import 'package:cliving_front/screens/event.dart';
import 'package:flutter/material.dart';

class RecordScreen extends StatefulWidget {
  DateTime selectedDay;
  Event selectedEvent;
  RecordScreen(
      {super.key, required this.selectedDay, required this.selectedEvent});
  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  @override
  Widget build(BuildContext context) {
    int year = widget.selectedDay.year;
    int month = widget.selectedDay.month;
    int day = widget.selectedDay.day;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 205, 205, 205),
        // elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '$year년 $month월 $day일',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Selected Day: ${widget.selectedDay.toString()}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Text(
                'Selected Event: ${widget.selectedEvent.place}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Text(
                'Event Color: ${widget.selectedEvent.color}',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
