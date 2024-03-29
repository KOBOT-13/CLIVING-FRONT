import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime today = DateTime.now();
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      today = selectedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 80, 20, 30),
          child: TableCalendar(
            locale: "en_US",
            headerStyle: const HeaderStyle(
                formatButtonVisible: false, titleCentered: true),
            availableGestures: AvailableGestures.all,
            selectedDayPredicate: (day) => isSameDay(day, today),
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2024, 12, 31),
            focusedDay: today,
            onDaySelected: _onDaySelected,
            calendarStyle: CalendarStyle(
                defaultTextStyle: const TextStyle(color: Colors.grey),
                weekendTextStyle: const TextStyle(color: Colors.grey),
                markerDecoration: BoxDecoration(
                    color: Colors.blue[200], shape: BoxShape.circle)),
            eventLoader: (day) {
              if (day.day % 2 == 0) {
                return ['hi'];
              }
              return [];
            },
          ),
        ),
      ),
    );
  }
}
