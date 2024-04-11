import 'package:cliving_front/screens/event.dart';
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

  @override
  void initState() {
    super.initState();
    placeController = TextEditingController(text: widget.selectedEvent.place);
  }

  @override
  void dispose() {
    placeController.dispose(); // Dispose the controller when done
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
                        readOnly: !isEditing, // 수정 모드에 따라 읽기 전용 설정
                      ),
                    ),
                    IconButton(
                      iconSize: 20,
                      icon: isEditing
                          ? const Icon(Icons.check)
                          : const Icon(Icons.edit),
                      onPressed: () {
                        setState(() {
                          isEditing = !isEditing; // 수정 버튼 클릭 시 수정 모드 변경
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
              Text(
                'Selected Day: ${widget.selectedDay.toString()}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Text(
                'Selected Event: ${widget.selectedEvent.place}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Text(
                'Event Color: ${widget.selectedEvent.color}',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
