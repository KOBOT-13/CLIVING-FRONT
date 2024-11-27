import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import '../widgets/custom_toast.dart';
import 'package:cliving_front/controllers/auth_controller.dart';
import 'package:get/get.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  Map colorMap = {
    'orange': Colors.orange,
    'yellow': Colors.yellow,
    'green': Colors.green,
    'blue': Colors.blue,
    'navy': const Color.fromRGBO(0, 0, 55, 1),
    'red': Colors.red,
    'pink': Color.fromARGB(255, 253, 125, 168),
    'purple': Colors.purple,
    'grey': Colors.grey,
    'brown': Colors.brown,
    'black': Colors.black,
    'white': Colors.white,
  };

  CameraController? _controller;
  final AuthController authController = Get.find<AuthController>();
  late final accessToken;
  Future<void>? _initializeControllerFuture;
  late List<CameraDescription> _cameras;
  XFile? file;
  XFile? video;
  bool _buttonCheck = false;
  bool isSelectingStartHold = true;
  bool _recordingCheck = false;
  Future<Map<int, List<dynamic>>>? imageHoldInfos;
  List<int> keys = [];
  int? first_image_id;
  String? dateFormat;
  String selectedColor = "";
  List<String> selectedColorList = [];
  double _scale = 1.0;
  double _previousScale = 1.0;
  double _maxZoomLevel = 0;
  double _minZoomLevel = 0;
  late int imageWidth = 0;
  late int imageHeight = 0;
  int clickedHold = 0;

  @override
  void initState() {
    super.initState();
    findCameras();
    accessToken = authController.accessToken.value;
  }

  Future<void> findCameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    _cameras = await availableCameras();
    setCamera();
    setState(() {});
  }

  Future<Map<int, List<dynamic>>> fetchData(var data) async {
    // 비동기 작업 시뮬레이션 (예: 네트워크 요청)
    // await Future.delayed(Duration(seconds: 1));
    Map<int, List<dynamic>> tmp = {};
    for (var d in data) {
      tmp[d['index_number']] = [
        [d['x1'], d['y1'], d['x2'], d['y2']],
        true
      ];
    }
    return tmp;
  }

  Future<void> fetchZoomLevel() async {
    // 디바이스 최대 줌 크기 체크. 15배 이상 가능할 경우 15배로 설정
    _maxZoomLevel = await _controller!.getMaxZoomLevel() ?? 1.0;
    if (_maxZoomLevel > 15) _maxZoomLevel = 15.0;
    // 디바이스 최소 줌 크기 체크.
    _minZoomLevel = await _controller!.getMinZoomLevel() ?? 1.0;
  }

  void setCamera() {
    if (_cameras.isNotEmpty) {
      _controller = CameraController(_cameras[0], ResolutionPreset.max,
          enableAudio: true, imageFormatGroup: ImageFormatGroup.yuv420);
      _initializeControllerFuture =
          _controller?.initialize().catchError((Object e) {
        if (e is CameraException) {
          switch (e.code) {
            case 'CameraAccessDenied':
              print("CameraController Error : CameraAccessDenied");
              break;
            default:
              print("CameraController Error");
              break;
          }
        }
      });
    }
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) {
      return;
    }
    try {
      // 사진 촬영
      final XFile newFile = await _controller!.takePicture();
      setState(() {
        file = newFile;
      });
      final bytes = await File(newFile.path).readAsBytes();
      final image = img.decodeImage(bytes);
      imageHeight = image!.height;
      imageWidth = image.width;
      // 사진 벡엔드에 보내는 코드
      try {
        String apiAddress = dotenv.get("API_ADDRESS");
        final request = http.MultipartRequest(
            'POST', Uri.parse("$apiAddress/v1/upload/image/"));
        request.files
            .add(await http.MultipartFile.fromPath('image', file!.path));
        request.headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        });
        var response = await request.send();
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);
        setState(() {
          imageHoldInfos = fetchData(jsonResponse["holds"]);
        });
        first_image_id = jsonResponse["holds"][0]["first_image"];

        showCustomToast(context, "시작 홀드를 선택해 주세요.\n만약 인식이 잘되지 않았다면 다시 촬영해주세요.");
      } catch (e) {
        print('Unexpected error: $e');
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  void _showColorModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Center(child: Text('홀드 색상을 선택하세요')),
              titleTextStyle: const TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
              content: SingleChildScrollView(
                child: Center(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: colorMap.keys.map((colorKey) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            selectedColor = colorKey;
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 50.0,
                              height: 50.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorMap[colorKey],
                                border:
                                    Border.all(width: 1.5, color: Colors.grey),
                              ),
                            ),
                            if (selectedColor == colorKey)
                              Icon(
                                Icons.check,
                                color: (selectedColor == 'white')
                                    ? Colors.black
                                    : Colors.white,
                                size: 30.0,
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('영상 촬영 시작'),
                  onPressed: () {
                    selectedColorList.add(selectedColor);
                    if (!_recordingCheck) {
                      checkPage(); // 오늘 날짜에 생성된 Page가 있는지 확인 후 create
                      _controller!.startVideoRecording();
                      _recordingCheck = true;
                      file = null;
                      showCustomToast(context, "동영상 촬영이 시작되었습니다.");
                    }
                    Navigator.of(context).pop(selectedColor);
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((selected) {
      if (selected != null) {
        setState(() {
          selectedColor = selected;
        });
      }
    });
  }

  Future<void> checkPage() async {
    // 오늘 날짜에 생성된 페이지가 있는지 확인
    var d = DateTime.now();
    dateFormat = DateFormat("yyMMdd").format(d).toString();
    String apiAddress = dotenv.get("API_ADDRESS");
    final url = Uri.parse('$apiAddress/v1/page/$dateFormat/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorizatoin': 'Bearer $accessToken',
      },
    );
    if (response.statusCode == 404) {
      //404 not found, 페이지가 존재하지 않을 경우
      createPage();
    } else {
      throw Exception('fail to check page');
    }
    print(response.statusCode);
  }

  Future<void> createPage() async {
    var d = DateTime.now();
    dateFormat = DateFormat("yyMMdd").format(d).toString();
    String apiAddress = dotenv.get("API_ADDRESS");
    final url = Uri.parse('$apiAddress/v1/page/');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'date': dateFormat,
          'climbing_center_name': "클라이밍장 이름을 입력해주세요.",
          // 'bouldering_clear_color': selectedColorList,
        }));
    print(response.statusCode);
  }

  Future<void> createClip(String videoIdArg) async {
    String apiAddress = dotenv.get("API_ADDRESS");
    String videoId = videoIdArg;
    final url = Uri.parse('$apiAddress/v1/video/$videoId/create_clip/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorizatoin': 'Bearer $accessToken',
      },
    );
    print(response.statusCode);
  }

  Future<void> createCheckpoint(String videoIdArg) async {
    String apiAddress = dotenv.get("API_ADDRESS");
    String videoId = videoIdArg;
    final url = Uri.parse('$apiAddress/v1/video/$videoId/create_checkpoint/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorizatoin': 'Bearer $accessToken',
      },
    );
    print(response.statusCode);
  }

  Future<String> stopRecording() async {
    XFile? file = await _controller!.stopVideoRecording();
    setState(() {
      video = file;
      _recordingCheck = false;
    });
    // 영상 저장 API 실행
    try {
      String apiAddress = dotenv.get("API_ADDRESS");
      final request =
          http.MultipartRequest('POST', Uri.parse("$apiAddress/v1/video/"));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });
      request.files
          .add(await http.MultipartFile.fromPath('videofile', file.path));
      request.fields['video_color'] = selectedColor;
      request.fields['page_id'] = dateFormat!;
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print('Status Code: ${response.statusCode}');
      var responseData = json.decode(response.body);
      String videoId = responseData['custom_id'];
      return videoId;
    } catch (e) {
      print('Error: $e');
      return 'Error: $e';
    }
  }

  Future<void> fetchTop() async {
    String apiAddress = dotenv.get("API_ADDRESS");
    try {
      final url = Uri.parse('$apiAddress/v1/hold/$first_image_id/${keys[0]}/');
      final response = await http.put(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: json.encode({
            'is_top': true,
          }));
      print(response.statusCode);
    } catch (e) {
      print('Error for key: ${keys[0]}, Error: $e');
    }
  }

  Future<void> fetchStart() async {
    String apiAddress = dotenv.get("API_ADDRESS");
    for (int key in keys) {
      try {
        final url = Uri.parse('$apiAddress/v1/hold/$first_image_id/$key/');
        final response = await http.put(url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: json.encode({
              'is_start': true,
            }));
        print('Response for key: $key, StatusCode: ${response.statusCode}');
        showCustomToast(context, "탑 홀드를 선택해주세요.");
      } catch (e) {
        print('Error for key: $key, Error: $e');
      }
    }
    keys.clear();
  }

  Future<void> resetImageHoldInfos() async {
    // Future<Map<int, List<dynamic>>>를 실제 Map으로 변환하여 값 가져오기
    Map<int, List<dynamic>>? holdInfos = await imageHoldInfos;

    // 값이 존재하는 경우 for 루프를 사용하여 모든 값을 변경
    if (holdInfos != null) {
      holdInfos.forEach((key, value) {
        // 원하는 변경 작업 수행
        value[1] = true; // 예시: 두 번째 요소를 false로 변경
      });
      clickedHold = 0;
      // 변경된 값을 다시 상태에 반영
      setState(() {
        imageHoldInfos = Future.value(holdInfos);
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _initializeControllerFuture == null) {
      return Container(); // 카메라가 없거나 초기화에 실패한 경우
    }
    return Stack(
      children: [
        Center(
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                fetchZoomLevel();
                return GestureDetector(
                    onScaleStart: (ScaleStartDetails details) {
                      _previousScale = _scale;
                    },
                    onScaleUpdate: (ScaleUpdateDetails details) {
                      setState(() {
                        if (!_recordingCheck) {
                          _scale = (_previousScale * details.scale)
                              .clamp(_minZoomLevel, _maxZoomLevel); // 줌 범위 제한
                          _controller!.setZoomLevel(_scale); // 줌 레벨 설정
                        }
                      });
                    },
                    onScaleEnd: (ScaleEndDetails details) {
                      _previousScale = 1.0;
                    },
                    child: Stack(
                      children: [
                        CameraPreview(
                          _controller!,
                        ),
                        // 오른쪽 하단에 배율 표시
                        Positioned(
                          bottom: 16.0,
                          right: 16.0,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              "${_scale.toStringAsFixed(1)}x", // 배율 텍스트
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16.0),
                            ),
                          ),
                        ),
                      ],
                    ));
              } else {
                return const Center(
                    child: CircularProgressIndicator(
                  strokeWidth: 10,
                ));
              }
            },
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: GestureDetector(
              onTap: () async {
                if (!_recordingCheck) {
                  _takePicture();
                } else {
                  String videoId = await stopRecording();
                  await createCheckpoint(videoId);
                  await createClip(videoId);
                  _recordingCheck = false;
                }
              },
              child: Icon(
                  (_recordingCheck)
                      ? Icons.radio_button_checked_rounded
                      : Icons.camera,
                  size: 70,
                  color: (_recordingCheck) ? Colors.red : Colors.black),
            ),
          ),
        ),
        if (file != null) // 조건을 검사하여 file이 null이 아닌 경우에만 Positioned 위젯을 생성
          Stack(
            children: [
              Positioned.fill(
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        color: Colors.black.withOpacity(0.1),
                      ))),
            ],
          ),
        if (file != null)
          Center(
            child: SizedBox(
              width: imageWidth.toDouble(),
              height: imageHeight.toDouble(),
              child: Stack(children: [
                Positioned.fill(
                  child: Image(image: XFileImage(file!)),
                ),
                Container(
                  alignment: const Alignment(-0.9, 0.99),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      surfaceTintColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        file = null;
                        imageHoldInfos = null;
                        clickedHold = 0;
                        _buttonCheck = false;
                        isSelectingStartHold = true;
                        keys.clear();
                      });
                    },
                    child: const Text("재촬영"),
                  ),
                ),
                Container(
                  alignment: const Alignment(0.9, 0.99),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      surfaceTintColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        if (_buttonCheck) {
                          if (isSelectingStartHold) {
                            fetchStart();
                            isSelectingStartHold = false;
                            _buttonCheck = false;
                            resetImageHoldInfos();
                          } else {
                            fetchTop();
                            if (!_recordingCheck) {
                              _showColorModal(context);
                            }
                          }
                        } else {
                          showCustomToast(context, "홀드를 선택해주세요.");
                        }
                      });
                    },
                    child: const Text("확정"),
                  ),
                ),
                FutureBuilder<Map<int, List<dynamic>>>(
                  future: imageHoldInfos,
                  builder: ((context, snapshot) {
                    if (imageHoldInfos == null) {
                      return Container();
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox.shrink();
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error'));
                    } else {
                      Map<int, List<dynamic>> buttonHold = snapshot.data!;
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(children: [
                            for (var t in buttonHold.entries)
                              Positioned(
                                top: (t.value[0][1]) /
                                    imageHeight *
                                    constraints.maxHeight,
                                right: (t.value[0][0]) /
                                    imageWidth *
                                    constraints.maxWidth,
                                child: SizedBox(
                                  width: (t.value[0][2] /
                                          imageWidth *
                                          constraints.maxWidth) -
                                      (t.value[0][0] /
                                          imageWidth *
                                          constraints.maxWidth),
                                  height: (t.value[0][3] /
                                          imageHeight *
                                          constraints.maxHeight) -
                                      (t.value[0][1] /
                                          imageHeight *
                                          constraints.maxHeight),
                                  child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          if (isSelectingStartHold) {
                                            if (clickedHold < 2) {
                                              if (t.value[1]) {
                                                t.value[1] = false;
                                                keys.add(t.key);
                                                clickedHold++;
                                                _buttonCheck = true;
                                              } else {
                                                t.value[1] = true;
                                                keys.remove(t.key);
                                                clickedHold--;
                                              }
                                            } else {
                                              if (!t.value[1]) {
                                                t.value[1] = true;
                                                keys.remove(t.key);
                                                clickedHold--;
                                              }
                                            }
                                            if (clickedHold == 0)
                                              _buttonCheck = false;
                                          } else {
                                            buttonHold.entries
                                                .forEach((element) {
                                              if (!element.value[1]) {
                                                element.value[1] = true;
                                              }
                                              t.value[1] = false;
                                              _buttonCheck = true;
                                              keys.add(t.key);
                                            });
                                          }
                                        });
                                      },
                                      child: Text(""),
                                      style: ButtonStyle(
                                          shape: WidgetStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.zero, // 각진 모서리
                                            ),
                                          ),
                                          side: WidgetStateProperty.resolveWith<
                                              BorderSide>((states) {
                                            return BorderSide(
                                              color: colorMap["orange"],
                                              width: 2.0,
                                            );
                                          }),
                                          backgroundColor: WidgetStateProperty
                                              .resolveWith<Color>((states) {
                                            if (t.value[1]) {
                                              return Colors.transparent;
                                            } else {
                                              return Color.fromRGBO(
                                                  0, 0, 0, 0.494);
                                            }
                                          }))),
                                ),
                              ),
                          ]);
                        },
                      );
                    }
                  }),
                ),
              ]),
            ),
          )
      ],
    );
  }
}
