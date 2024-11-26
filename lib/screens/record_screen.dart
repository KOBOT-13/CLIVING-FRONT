import 'dart:convert';
import 'package:cliving_front/controllers/auth_controller.dart';
import 'package:cliving_front/screens/event.dart';
import 'package:cliving_front/screens/video_player_screen.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ribbon_widget/ribbon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
  final AuthController authController = Get.find<AuthController>();
  late Future<Map<String, dynamic>> futurePage;
  late Future<List<String>> videoUrls;
  late Future<List<String>> thumbnailUrls;
  late Future<List<String>> colorsList;
  late Future<List<String>> typesList;
  late TextEditingController placeController;
  late DateTime _selectedDay;
  bool isEditing = false;

  String pageId = '';

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDay;
    pageId = _getPageId(_selectedDay);
    futurePage = _getPage();
    thumbnailUrls = getThumbnailUrls();
    videoUrls = getVideoUrls();
    colorsList = getColorsList();
    typesList = getTypesList();
  }

  @override
  void dispose() {
    placeController.dispose();
    super.dispose();
  }

  String _getPageId(DateTime date) {
    final String year =
        (date.year % 100).toString().padLeft(2, '0'); // 연도 두 자릿수
    final String month = date.month.toString().padLeft(2, '0'); // 월 두 자릿수
    final String day = date.day.toString().padLeft(2, '0'); // 일 두 자릿수
    return '$year$month$day';
  }

  Future<Map<String, dynamic>> _getPage() async {
    String apiAddress = dotenv.get("API_ADDRESS");
    final accessToken = authController.accessToken.value;

    final url = Uri.parse('$apiAddress/v1/page/$pageId');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> readPage =
          json.decode(utf8.decode(response.bodyBytes));
      return readPage;
    } else {
      throw Exception('Failed to read page.');
    }
  }

  Future<void> _updatePlace(String newPlace) async {
    String apiAddress = dotenv.env['API_ADDRESS']!;
    final accessToken = authController.accessToken.value;
    final url = Uri.parse('$apiAddress/v1/page/$pageId/');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'climbing_center_name': newPlace,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          futurePage = _getPage();
          placeController.text = newPlace;
          isEditing = false;
        });
      } else {
        throw Exception('Failed to update place');
      }
    } catch (e) {
      print('Error updating place: $e');
      // Handle error as needed
    }
  }

  Future<List<String>> getVideoUrls() async {
    String apiAddress = dotenv.env['API_ADDRESS']!;
    final url = Uri.parse('$apiAddress/v1/videoclips/by_page/paths/$pageId/');
    final accessToken = authController.accessToken.value;

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> readVideoUrls =
          json.decode(utf8.decode(response.bodyBytes));
      return readVideoUrls
          .map((video) => '$apiAddress/$video')
          .toList()
          .cast<String>();
    } else {
      throw Exception('Failed to load video');
    }
  }

  Future<List<String>> getThumbnailUrls() async {
    String apiAddress = dotenv.env['API_ADDRESS']!;
    final accessToken = authController.accessToken.value;
    final url =
        Uri.parse('$apiAddress/v1/videoclips/by_page/thumbnails/$pageId/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> readThumbnailUrls =
          json.decode(utf8.decode(response.bodyBytes));
      return readThumbnailUrls
          .map((thumbnail) => '$apiAddress/$thumbnail')
          .toList()
          .cast<String>();
    } else {
      throw Exception('Failed to load thumbnails');
    }
  }

  Future<List<String>> getColorsList() async {
    String apiAddress = dotenv.env['API_ADDRESS']!;
    final accessToken = authController.accessToken.value;
    final url = Uri.parse('$apiAddress/v1/videoclips/by_page/colors/$pageId/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> readColorsList =
          json.decode(utf8.decode(response.bodyBytes));
      return readColorsList.toList().cast<String>();
    } else {
      throw Exception('Failed to load colors');
    }
  }

  Future<List<String>> getTypesList() async {
    String apiAddress = dotenv.env['API_ADDRESS']!;
    final accessToken = authController.accessToken.value;
    final url = Uri.parse('$apiAddress/v1/videoclips/by_page/types/$pageId/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> readTypesList =
          json.decode(utf8.decode(response.bodyBytes));
      return readTypesList.map((type) => type.toString()).toList();

      //readTypesList.toList().cast<String>();
    } else {
      throw Exception('Failed to load types');
    }
  }

  Future<int> getThumbnailLength() async {
    try {
      List<String> thumbnails = await getThumbnailUrls();
      return thumbnails.length;
    } catch (e) {
      print('Error counting thumbnails: $e');
      return 0;
    }
  }

  Future<void> _launchURL(String nowUrl) async {
    final Uri url = Uri.parse(nowUrl);
    try {
      if (!await launchUrl(
        url,
        mode: LaunchMode.inAppWebView,
      )) {
        throw Exception('Could not launch $url');
      }
    } on PlatformException catch (e) {
      // 에러 로그 출력
      print('PlatformException: ${e.message}');
    } catch (e) {
      // 일반 예외 처리
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    int year = widget.selectedDay.year;
    int month = widget.selectedDay.month;
    int day = widget.selectedDay.day;

    final Map<String, dynamic> colorMap = {
      'orange': Colors.orange,
      'yellow': Colors.yellow,
      'green': Colors.green,
      'blue': Colors.blue,
      'navy': const Color.fromRGBO(0, 0, 55, 1),
      'red': Colors.red,
      'pink': const Color.fromARGB(255, 253, 125, 168),
      'purple': Colors.purple,
      'grey': Colors.grey,
      'brown': Colors.brown,
      'black': Colors.black,
      'white': Colors.white,
    };

    String getTitle(String type) {
      if (type == '1') {
        return '성공';
      }
      return '';
    }

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
        body: FutureBuilder<Map<String, dynamic>>(
            future: futurePage,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Failed to load data'));
              } else if (!snapshot.hasData) {
                return const Center(child: Text('No data available'));
              } else {
                Map<String, dynamic> pageData = snapshot.data!;
                String climbingCenterName = pageData['climbing_center_name'];
                placeController =
                    TextEditingController(text: climbingCenterName);
                List<String> boulderingClearColor =
                    List<String>.from(pageData['bouldering_clear_color']);
                String startTime = pageData['today_start_time'];
                String endTime = pageData['today_end_time'];
                DateTime startDateTime =
                    DateTime.parse('2024-04-19 $startTime');
                DateTime endDateTime = DateTime.parse('2024-04-19 $endTime');
                // List<int> colorSuccessCounter =
                //     List<int>.from(pageData['color_success_counter']);
                // List<int> colorFailCounter =
                //     List<int>.from(pageData['color_fail_counter']);
                List<int> colorTotalCounter =
                    List<int>.from(pageData['bouldering_clear_color_counter']);

                int startH = startDateTime.hour;
                int startM = startDateTime.minute;
                // int startS = startDateTime.second;
                int finishH = endDateTime.hour;
                int finishM = endDateTime.minute;
                // int finishS = endDateTime.second;

                return Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.15),
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
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.black),
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
                                    if (isEditing) {
                                      _updatePlace(placeController.text);
                                    }
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
                                '${startH < 10 ? '0' : ''}$startH시 ${startM < 10 ? '0' : ''}$startM분 ',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const Text(
                                ' ~ ',
                                style: TextStyle(fontSize: 20),
                              ),
                              Text(
                                '${finishH < 10 ? '0' : ''}$finishH시 ${finishM < 10 ? '0' : ''}$finishM분',
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
                              boulderingClearColor.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(
                                    right: 10), // 각 원 사이의 간격 조정
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 40, // 원의 너비
                                      height: 40, // 원의 높이
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.grey, width: 1.0),
                                        color: colorMap[
                                                boulderingClearColor[index]] ??
                                            Colors.transparent,
                                      ),
                                    ),
                                    Text(
                                      colorTotalCounter.length > index
                                          ? (colorTotalCounter[index])
                                              .toString()
                                          : '',
                                      style: const TextStyle(
                                        color: Colors
                                            .white, // 숫자 색상 (필요에 따라 변경 가능)
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
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
                          child: FutureBuilder<List<List<String>>>(
                            future: Future.wait([
                              thumbnailUrls,
                              videoUrls,
                              colorsList,
                              typesList,
                            ]),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return const Center(
                                    child: Text('Failed to load videos'));
                              } else if (!snapshot.hasData) {
                                return const Center(
                                    child: Text('No videos available'));
                              } else {
                                List<String> thumbnails = snapshot.data![0];
                                List<String> videos = snapshot.data![1];
                                List<String> colors = snapshot.data![2];
                                List<String> types = snapshot.data![3];

                                return GridView.builder(
                                  padding: const EdgeInsets.all(10),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3, // 한 행에 보여질 동영상 수
                                    crossAxisSpacing: 10, // 동영상 간 가로 간격
                                    mainAxisSpacing: 10, // 동영상 간 세로 간격
                                  ),
                                  itemCount: thumbnails.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        String nowUrl = videos[index];
                                        _launchURL(nowUrl);
                                      },
                                      child: Ribbon(
                                        nearLength: 13,
                                        farLength: 48,
                                        title: getTitle(types[index]),
                                        titleStyle: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                        color: colorMap[colors[index]] ??
                                            Colors.transparent,
                                        child: Image.network(
                                          thumbnails[index],
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }));
  }
}
