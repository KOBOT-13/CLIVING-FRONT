import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../controllers/auth_controller.dart';

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
  final url = Uri.parse('$apiAddress/v1/pages/$year/');
  final AuthController authController = Get.find<AuthController>();
  final accessToken = authController.accessToken.value;

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
    Map<DateTime, List<Event>> events = {};

    for (var eventData in jsonData) {
      try {
        String dateField = eventData['date_dateFieldValue'];
        String? startTime = eventData['today_start_time'];
        String? endTime = eventData['today_end_time'];

        // 날짜와 시간을 안전하게 변환
        if (startTime == null || endTime == null) {
          throw FormatException(
              "Invalid startTime or endTime: $startTime, $endTime");
        }

        DateTime date = DateTime.parse(dateField);
        DateTime startDateTime = DateTime.parse("$dateField $startTime");
        DateTime endDateTime = DateTime.parse("$dateField $endTime");

        // Event 객체 생성
        Event event = Event(
          place: eventData['climbing_center_name'] ?? "Unknown",
          color: List<String>.from(eventData['bouldering_clear_color'] ?? []),
          start: startDateTime,
          finish: endDateTime,
        );

        if (events[date] == null) {
          events[date] = [];
        }
        events[date]!.add(event);
      } catch (e) {
        print("Error processing event data: $e");
        print("Invalid Event Data: $eventData");
      }
    }
    return events;
  } else {
    throw Exception('Failed to fetch events.');
  }
}
