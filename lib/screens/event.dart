import 'package:table_calendar/table_calendar.dart';
import 'dart:collection';

class Event {
  String place;
  List<String> color;
  DateTime start;
  DateTime finish;

  Event(
      {this.place = '암장을 입력해주세요',
      required this.color,
      required this.start,
      required this.finish});

  @override
  String toString() => '';

  String getPlace() {
    return place;
  }

  List<String> getColor() {
    return color;
  }

  int getColorLength() {
    return color.length;
  }

  DateTime getStart() {
    return start;
  }

  DateTime getFinish() {
    return finish;
  }
}

final event = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_eventSource);

final _eventSource = {
  DateTime(2024, 4, 3): [
    Event(
        place: '타잔 101 클라이밍',
        color: ['red'],
        start: DateTime(2024, 4, 3, 10, 0),
        finish: DateTime(2024, 4, 3, 12, 0))
  ],
  DateTime(2024, 4, 19): [
    Event(
        place: '서울숲 클라이밍1',
        color: ['blue', 'red', 'green'],
        start: DateTime(2024, 4, 19, 10, 0),
        finish: DateTime(2024, 4, 19, 12, 0)),
  ],
  DateTime(2024, 4, 25): [
    Event(
        place: '건대 클라이밍',
        color: ['blue'],
        start: DateTime(2024, 4, 25, 10, 0),
        finish: DateTime(2024, 4, 25, 12, 0))
  ]
};

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}
