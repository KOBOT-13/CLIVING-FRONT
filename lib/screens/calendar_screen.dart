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
    List<Event> eventList = event[day] ?? [];
    return eventList;
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
    switch (colorString) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      // 추가적인 색상 처리
      default:
        return Colors.black; // 기본값 설정
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
                          Event event = events[index] as Event; // 현재 이벤트 가져오기
                          List<String> colorStr =
                              event.getColor(); // 이벤트의 color 가져오기
                          return Container(
                            width: 12,
                            height: 10,
                            margin: const EdgeInsets.only(top: 35),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: getColorFromString(colorStr[
                                  0]), // getColorFromString 함수를 통해 컬러 설정
                            ),
                          );
                        },
                      );
                    }
                    return null; // 이벤트가 없는 경우 아무런 마커도 표시하지 않음
                  },
                ),
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
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
                                    selectedEvent: value[index],
                                  ),
                                );
                              },
                              leading: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      getColorFromString(value[index].color[0]),
                                ),
                              ),
                              title: Text(value[index].place),
                              subtitle: Text(value[index].color[0]),
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
