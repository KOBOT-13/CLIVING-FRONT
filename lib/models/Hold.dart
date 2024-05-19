class Hold{
  final String color;
  final bool isTop;
  final double x1;
  final double x2;
  final double y1;
  final double y2;
  final int frameId;

  Hold({
    required this.color,
    required this.isTop,
    required this.x1,
    required this.x2,
    required this.y1,
    required this.y2,
    required this.frameId,
  });

  factory Hold.fromJson(Map<String, dynamic> json){
    return Hold(
      color: json["color"],
      isTop: json["is_top"],
      x1: json["x1"],
      x2: json["x2"],
      y1: json["y1"],
      y2: json["y2"],
      frameId: json["frame_id"],
    );
  }
}