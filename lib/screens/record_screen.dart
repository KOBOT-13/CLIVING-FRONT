import 'package:cliving_front/screens/event.dart';
import 'package:cliving_front/screens/video_player_screen.dart';
import 'package:flutter/material.dart';

class RecordScreen extends StatefulWidget {
  DateTime selectedDay;
  Event selectedEvent;

  RecordScreen({
    super.key,
    required this.selectedDay,
    required this.selectedEvent,
  });

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late TextEditingController placeController;
  bool isEditing = false;

  List<String> videoThumbnailUrls = [
    'assets/images/climbing.jpeg',
    'assets/images/climbing.jpeg',
    'assets/images/climbing.jpeg',
    'assets/images/climbing.jpeg',
    'assets/images/climbing.jpeg',
    'assets/images/climbing.jpeg',
    'assets/images/climbing.jpeg',
    'assets/images/climbing.jpeg',
  ];

  List<String> videoUrls = [
    'assets/videos/CallbackLogo.mp4',
    'assets/videos/CallbackLogo.mp4',
    'assets/videos/CallbackLogo.mp4',
    'assets/videos/CallbackLogo.mp4',
    'assets/videos/CallbackLogo.mp4',
    'assets/videos/CallbackLogo.mp4',
    'assets/videos/CallbackLogo.mp4',
    'assets/videos/CallbackLogo.mp4',
  ];

  @override
  void initState() {
    super.initState();
    placeController = TextEditingController(text: widget.selectedEvent.place);
  }

  @override
  void dispose() {
    placeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int year = widget.selectedDay.year;
    int month = widget.selectedDay.month;
    int day = widget.selectedDay.day;
    int startH = widget.selectedEvent.start.hour;
    int startM = widget.selectedEvent.start.minute;
    int finishH = widget.selectedEvent.finish.hour;
    int finishM = widget.selectedEvent.finish.minute;
    final Map<String, Color> colorMap = {
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
    };

    final Color selectedColor =
        colorMap[widget.selectedEvent.color] ?? Colors.transparent;
    final colorList = widget.selectedEvent.getColor();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '$year년 $month월 $day일',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Text(
                  '장소',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: placeController,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                        keyboardType: TextInputType.text,
                        maxLines: null,
                        focusNode: FocusNode(),
                        readOnly: !isEditing,
                      ),
                    ),
                    IconButton(
                      iconSize: 20,
                      icon: isEditing
                          ? const Icon(Icons.check)
                          : const Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          isEditing = !isEditing;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Text(
                  '시간',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  children: [
                    Text(
                      '${startH < 10 ? '0' : ''}$startH : ${startM < 10 ? '0' : ''}$startM',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const Text(
                      ' ~ ',
                      style: TextStyle(fontSize: 20),
                    ),
                    Text(
                      '${finishH < 10 ? '0' : ''}$finishH : ${finishM < 10 ? '0' : ''}$finishM',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(15, 5, 0, 0),
                child: Text(
                  '볼더링',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 5, 0, 0),
                child: Row(
                  children: List.generate(
                    widget.selectedEvent.color.length,
                    (index) => Padding(
                      padding:
                          const EdgeInsets.only(right: 10), // 각 원 사이의 간격 조정
                      child: Container(
                        width: 40, // 원의 너비
                        height: 40, // 원의 높이
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey, width: 1.0),
                          color: colorMap[widget.selectedEvent.color[index]] ??
                              Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(15, 5, 0, 0),
                child: Text(
                  '영상 보기',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 한 행에 보여질 동영상 수
                    crossAxisSpacing: 10, // 동영상 간 가로 간격
                    mainAxisSpacing: 10, // 동영상 간 세로 간격
                  ),
                  itemCount: videoThumbnailUrls.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => VideoPlayerScreen(
                                  videoUrl: videoUrls[index])),
                        );
                      },
                      child: Image.asset(
                        videoThumbnailUrls[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
