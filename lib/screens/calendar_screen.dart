import 'package:cliving_front/screens/event.dart';
import 'package:cliving_front/screens/record_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime today = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<Event>> events = {};
  late final ValueNotifier<List<Event>> _selectedEvents;

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
  }

  @override
  void dispose() {
    //StatefulWidget이 제거될 때 호출되어 리소스를 해제함
    _selectedEvents.dispose(); //ValueNotifier 해제
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return event[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      // Call `setState()` when updating the selected day
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 30),
              child: TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2024, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  // to determine which day is currently selected
                  // true -> 'day' will be marked as selected
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: _onDaySelected,
                eventLoader: _getEventsForDay,
                locale: "en_US",
                headerStyle: const HeaderStyle(
                    formatButtonVisible: false, titleCentered: true),
                availableGestures: AvailableGestures.all,
                calendarStyle: CalendarStyle(
                    defaultTextStyle: const TextStyle(color: Colors.grey),
                    weekendTextStyle: const TextStyle(color: Colors.grey),
                    markerDecoration: BoxDecoration(
                        color: Colors.blue[200], shape: BoxShape.circle)),
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
            ),
            // Align(
            //   alignment: Alignment.bottomRight,
            //   child: ElevatedButton(
            //       onPressed: () {
            //         Get.to(
            //           () => RecordScreen(selectedDay: focusedDay),
            //         );
            //       },
            //       child: const Text('button')),
            // ),
            Expanded(
              child: ValueListenableBuilder<List<Event>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              onTap: () {
                                Get.to(
                                  () => RecordScreen(
                                      selectedDay: _selectedDay,
                                      selectedEvent: value[index]),
                                );
                              },
                              leading: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                              ),
                              title: Text(value[index].place),
                              subtitle: Text(value[index].color),
                            ),
                          );
                        });
                  }),
            )
          ],
        ),
      ),
    );
  }
}
