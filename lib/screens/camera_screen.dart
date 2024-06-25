import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

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
  Future<void>? _initializeControllerFuture;
  late List<CameraDescription> _cameras;
  XFile? file;
  XFile? video;
  bool _buttonCheck = false;
  bool _recordingCheck = false;
  Future<Map<int, List<dynamic>>>? imageHoldInfos;
  int? key;
  int? first_image_id;
  String? dateFormat;
  String selectedColor = "";
  List<String> selectedColorList = [];

  @override
  void initState() {
    super.initState();
    findCameras();
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

  void setCamera() {
    if (_cameras.isNotEmpty) {
      print("실행됨");
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
      // 사진 벡엔드에 보내는 코드
      try {
        String apiAddress = dotenv.get("API_ADDRESS");
        print(apiAddress);
        final request = http.MultipartRequest(
            'POST', Uri.parse("$apiAddress/v1/upload/image/"));
        request.files
            .add(await http.MultipartFile.fromPath('image', file!.path));
        var response = await request.send();
        print(response.statusCode);
        var responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);
        setState(() {
          imageHoldInfos = fetchData(jsonResponse["holds"]);
        });
        first_image_id = jsonResponse["holds"][0]["first_image"];
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
                    print(selectedColor);
                    if (!_recordingCheck) {
                      createPage();
                      _controller!.startVideoRecording();
                      _recordingCheck = true;
                      file = null;
                      fetchTop();
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
          'bouldering_clear_color': selectedColorList,
        }));
    print(response.statusCode);
    try{
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'date': dateFormat,
          'climbing_center_name' : "클라이밍장 이름을 입력해주세요.",
        })
      );
      print(response.statusCode);
    } catch(e){
      print(e);
    }
  }

  Future<void> stopRecording() async {
    XFile? file = await _controller!.stopVideoRecording();
    setState(() {
      video = file;
    });
    // 영상 저장 API 실행
    try {
      String apiAddress = dotenv.get("API_ADDRESS");
      final request =
          http.MultipartRequest('POST', Uri.parse("$apiAddress/v1/video/"));
      request.files
          .add(await http.MultipartFile.fromPath('videofile', file.path));
      request.fields['video_color'] = selectedColor;
      request.fields['page_id'] = dateFormat!;
      var response = await request.send();
      print(response.statusCode);
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchTop() async {
    String apiAddress = dotenv.get("API_ADDRESS");
    final url = Uri.parse('$apiAddress/v1/hold/$first_image_id/$key/');
    final response = await http.put(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'is_top': true,
        }));
    print(response.statusCode);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
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
                return CameraPreview(_controller!);
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
              onTap: () {
                if (!_recordingCheck) {
                  _takePicture();
                } else {
                  stopRecording();
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
          Positioned.fill(
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    color: Colors.black.withOpacity(0.1),
                  ))),
        if (file != null)
          Center(
            child: SizedBox(
              width: 393.0,
              height: 524.0,
              child: Stack(children: [
                Positioned.fill(
                  child: Image(image: XFileImage(file!)),
                ),
                Container(
                  alignment: const Alignment(-0.9, 0.9),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        surfaceTintColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onPressed: (){
                        setState(() {
                          file = null;
                          imageHoldInfos = null;
                        });
                      },
                      child: Text("재촬영"),
                    ),
                  ),
                  Container(
                    alignment: Alignment(0.9, 0.9),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        surfaceTintColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                          textStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    onPressed: () {
                      setState(() {
                        if (_buttonCheck) {
                          if (!_recordingCheck) {
                            _showColorModal(context);
                            
                          }
                        } else {
                          Fluttertoast.showToast(
                            msg: "홀드를 선택해주세요.",
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: const Color.fromRGBO(0, 0, 0, 0.8),
                          );
                        }
                      });
                    },
                    child: const Text("확정"),
                    ),
                  ),
                  FutureBuilder<Map<int, List<dynamic>>>(
                    future: imageHoldInfos,
                    builder: ((context, snapshot){
                      if(imageHoldInfos == null){
                        return Container();
                      }
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return SizedBox.shrink();
                      }
                      else if(snapshot.hasError){
                        return Center(child: Text('Error'));
                      }
                      else{
                        Map<int, List<dynamic>> buttonHold = snapshot.data!;
                        return LayoutBuilder(
                            builder: (context, constraints) {
                              print(constraints.maxHeight);
                              print(constraints.maxWidth);
                              for(var t in buttonHold.entries){
                                print(t.value);
                              }
                              return Stack(
                                children: [
                                  for(var t in buttonHold.entries)
                                    Positioned(
                                      top:  (t.value[0][0]) / 3024.0 * constraints.maxWidth,
                                      right: (t.value[0][1]) / 4032.0 * constraints.maxHeight,
                                      child: SizedBox(
                                        width:  (t.value[0][3] / 4032.0 * constraints.maxHeight) - (t.value[0][1] / 4032.0 * constraints.maxHeight),
                                        height:(t.value[0][2] / 3024.0 * constraints.maxWidth) - (t.value[0][0] / 3024.0 * constraints.maxWidth),
                                        child: OutlinedButton(
                                          onPressed: (){
                                            setState(() {
                                              buttonHold.entries.forEach((element) {
                                                if(!element.value[1]){
                                                  element.value[1] = true;
                                                }
                                                t.value[1] = false;
                                                _buttonCheck = true;
                                                key = t.key;
                                              });
                                            });
                                          },
                                          child: Text(""),
                                          style: ButtonStyle(
                                            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.zero, // 각진 모서리
                                              ),
                                            ),
                                            side: WidgetStateProperty.resolveWith<BorderSide>(
                                              (states){
                                                return BorderSide(
                                                  color: colorMap["orange"],
                                                  width: 2.0,
                                                );
                                              }
                                            ),
                                            backgroundColor: WidgetStateProperty.resolveWith<Color>(
                                              (states) {
                                                if(t.value[1]){
                                                  return Colors.transparent;
                                                }
                                                else{
                                                  return Color.fromRGBO(0, 0, 0, 0.494);
                                                }
                                              }
                                            )
                                          )
                                        ),
                                      ),
                                    ),
                                ]
                              );     
                            },
                          );
                      }
                    }
                  ),
                ),
              ]),
            ),
          )
      ],
    );
  }
}
