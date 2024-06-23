import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'dart:ui';
import 'package:cliving_front/models/TestHold.dart';
import 'package:cliving_front/models/Hold.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';

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
    'pink': Colors.pink,
    'purple': Colors.purple,
    'grey': Colors.grey,
    'brown': Colors.brown,
    'black': Colors.black,
    'white': Colors.white,
  };

  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  late Future<List<Hold>> _holdInfo;
  late List<CameraDescription> _cameras;
  XFile? file;
  bool _buttonCheck = false;
  String selectedColor = '';

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

  void reHolds() {
    setState(() {
      _holdInfo = _callAPI();
    });
  }

  Future<List<Hold>> _callAPI() async {
    // API 호출 코드 작성
    Future<List<Hold>> tmp = Future.value(jsonString);
    return tmp;
  }

  void setCamera() {
    if (_cameras.isNotEmpty) {
      print("실행됨");
      _controller = CameraController(_cameras[0], ResolutionPreset.max,
          enableAudio: false, imageFormatGroup: ImageFormatGroup.yuv420);
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
                  child: const Text('선택 완료'),
                  onPressed: () {
                    print(selectedColor);
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
        Positioned.fill(
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
                _takePicture();
                reHolds();
              },
              child: const Icon(
                Icons.camera,
                size: 70,
                color: Colors.black,
              ),
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
          Stack(children: [
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
                    )),
                onPressed: () {
                  setState(() {
                    file = null;
                  });
                },
                child: const Text("재촬영"),
              ),
            ),
            Container(
              alignment: const Alignment(0.9, 0.9),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    surfaceTintColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )),
                onPressed: () {
                  setState(() {
                    if (_buttonCheck) {
                      print("영상 촬영 시작");
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
            FutureBuilder<List<Hold>>(
              future: _holdInfo,
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error'));
                } else {
                  List<Hold> buttonHold = snapshot.data!;
                  return Stack(children: [
                    for (Hold t in buttonHold)
                      Positioned(
                        top: t.y2,
                        left: t.x1,
                        bottom: t.y1,
                        right: t.x2,
                        child: SizedBox(
                          child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  for (var element in buttonHold) {
                                    if (!element.check) {
                                      print("실행됨");
                                      print(element.check);
                                      element.check = true;
                                    }
                                  }
                                  t.check = false;
                                  _buttonCheck = true;
                                });
                              },
                              style: ButtonStyle(side:
                                  WidgetStateProperty.resolveWith<BorderSide>(
                                      (states) {
                                return BorderSide(
                                  color: colorMap[t.color],
                                  width: 2.0,
                                );
                              }), backgroundColor:
                                  WidgetStateProperty.resolveWith<Color>(
                                      (states) {
                                if (t.check) {
                                  return Colors.transparent;
                                } else {
                                  return const Color.fromRGBO(0, 0, 0, 0.494);
                                }
                              })),
                              child: const Text("")),
                        ),
                      ),
                  ]);
                }
              }),
            ),
          ])
      ],
    );
  }
}
