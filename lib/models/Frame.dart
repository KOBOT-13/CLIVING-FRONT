import 'package:camera/camera.dart';

class Frame{
  final XFile image;

  Frame({
    required this.image,
  });

  factory Frame.fromJson(Map<String, dynamic> json){
    return Frame(
      image: json["image"],
    );
  }
}