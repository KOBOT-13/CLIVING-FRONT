import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cliving_front/screens/event.dart';
import 'package:cliving_front/screens/record_screen.dart';

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
    _fetchAndSetEvents();
  }

  Future<void> _fetchAndSetEvents() async {
    try {
      int currentYear = _selectedDay.year % 100;
      int currentMonth = _selectedDay.month;

      Map<DateTime, List<Event>> fetchedEvents =
          await fetchEvents(currentYear, currentMonth);
      setState(() {
        events = fetchedEvents;
        _selectedEvents.value = _getEventsForDay(_selectedDay);
      });
    } catch (error) {
      print('Failed to fetch events: $error');
    }
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    DateTime dayOnly = DateTime(day.year, day.month, day.day);
    return events[dayOnly] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  Color getColorFromString(String colorString) {
    switch (colorString.toLowerCase()) {
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
        return Colors.pink;
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

  void _refreshCalendarScreen() async {
    await _fetchAndSetEvents();
    setState(() {});
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
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: _onDaySelected,
                eventLoader: _getEventsForDay,
                locale: "en_US",
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: Colors.black38),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: Colors.black38),
                ),
                availableGestures: AvailableGestures.all,
                calendarStyle: CalendarStyle(
                    defaultTextStyle: const TextStyle(color: Colors.grey),
                    weekendTextStyle: const TextStyle(color: Colors.grey),
                    markerDecoration: BoxDecoration(
                        color: Colors.blue[200], shape: BoxShape.circle)),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (events.isNotEmpty) {
                      return ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          Event event = events[index] as Event;
                          List<String> colorStr = event.getColor();
                          return Container(
                            width: 12,
                            height: 10,
                            margin: const EdgeInsets.only(top: 35),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: getColorFromString(colorStr[0]),
                            ),
                          );
                        },
                      );
                    }
                    return null;
                  },
                ),
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                  _refreshCalendarScreen(); // 페이지가 변경될 때마다 데이터를 다시 가져옴
                },
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<Event>>(
                valueListenable: _selectedEvents,
                builder: (context, value, _) {
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      DateTime startTime = value[index].start;
                      DateTime finishTime = value[index].finish;

                      String formattedDate =
                          '${startTime.month}월 ${startTime.day}일';
                      String formattedStartTime =
                          '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
                      String formattedFinishTime =
                          '${finishTime.hour}:${finishTime.minute.toString().padLeft(2, '0')}';

                      String timeRange;
                      if (finishTime.difference(startTime).inHours >= 1) {
                        timeRange =
                            '$formattedStartTime - $formattedFinishTime';
                      } else {
                        timeRange = formattedStartTime;
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () async {
                            dynamic result = await Get.to(
                              () => RecordScreen(
                                selectedDay: _selectedDay,
                                selectedEvent: value[index],
                              ),
                            );
                            _refreshCalendarScreen();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.terrain_rounded,
                                  size: 30,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(value[index].place,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(
                                  height: 7,
                                ),
                                Row(
                                  children: [
                                    Text(formattedDate,
                                        style: const TextStyle(fontSize: 15)),
                                    const SizedBox(
                                      width: 3,
                                    ),
                                    Text(timeRange,
                                        style: const TextStyle(
                                          fontSize: 15,
                                        )),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: value[index].color.map((color) {
                                    return Container(
                                      width: 30,
                                      height: 30,
                                      margin: const EdgeInsets.only(left: 5),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: getColorFromString(color),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
