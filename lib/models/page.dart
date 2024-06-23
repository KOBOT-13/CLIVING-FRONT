class Page {
  final String? climbing_center_name;
  final Enum? bouldering_clear_color;
  final String? start_time;
  final String? end_time;
  final int? play_time;

  Page({
    required this.climbing_center_name,
    required this.bouldering_clear_color,
    required this.start_time,
    required this.end_time,
    required this.play_time,
  });

  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      climbing_center_name: json["climbing_center_name"],
      bouldering_clear_color: json["bouldering_clear_color"],
      start_time: json["start_time"],
      end_time: json["end_time"],
      play_time: json["play_time"],
    );
  }
}
