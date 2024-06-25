import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Event {
  String place;
  List<String> color;
  DateTime start;
  DateTime finish;

  Event({
    this.place = '암장을 입력해주세요',
    required this.color,
    required this.start,
    required this.finish,
  });

  @override
  // String toString() => '';
  String toString() {
    return 'Event(place: $place, color: $color, start: $start, finish: $finish)';
  }

  List<String> getColor() {
    return color;
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      place: json['climbing_center_name'],
      color: List<String>.from(json['bouldering_clear_color']),
      start: DateTime.parse(json['today_start_time']),
      finish: DateTime.parse(json['today_end_time']),
    );
  }
}

Future<Map<DateTime, List<Event>>> fetchEvents(int year) async {
  String apiAddress = dotenv.get("API_ADDRESS");
  final url = Uri.parse('$apiAddress/v1/pages/$year');

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
    Map<DateTime, List<Event>> events = {};

    for (var eventData in jsonData) {
      // API 응답에서 날짜와 시간을 파싱하는 부분
      DateTime date = DateTime.parse(eventData['date_dateFieldValue']);

      // 날짜와 시간을 함께 파싱하여 DateTime 객체로 변환
      DateTime startTime = DateTime.parse(
          "${eventData['date_dateFieldValue']} ${eventData['today_start_time']}");
      DateTime endTime = DateTime.parse(
          "${eventData['date_dateFieldValue']} ${eventData['today_end_time']}");

      // Event 객체 생성 시, 변환된 DateTime 객체를 사용
      Event event = Event(
        place: eventData['climbing_center_name'],
        color: List<String>.from(eventData['bouldering_clear_color']),
        start: startTime,
        finish: endTime,
      );

      if (events[date] == null) {
        events[date] = [];
      }
      events[date]!.add(event);
    }
    return events;
  } else {
    throw Exception('Failed to fetch events.');
  }
}
