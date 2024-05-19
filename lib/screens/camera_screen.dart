import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'dart:ui';
import 'package:cliving_front/models/TestHold.dart';
import 'package:cliving_front/models/Hold.dart';
import 'package:http/http.dart';
import 'dart:convert';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  Map colorMap = {
    'orange' : Colors.orange,
    'yellow' : Colors.yellow,
    'green' : Colors.green,
    'blue' : Colors.blue,
    'navy' : Color.fromRGBO(0, 0, 55, 1),
    'red' : Colors.red,
    'pink' : Colors.pink,
    'purple' : Colors.purple,
    'grey' : Colors.grey,
    'brown' : Colors.brown,
    'black' : Colors.black,
    'white' : Colors.white,
  };

  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  late Future<List<Hold>> _holdInfo;
  late List<CameraDescription> _cameras;
  XFile? file;
  
  @override
  void initState(){
    super.initState();
    findCameras();
  }
  Future<void> findCameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    _cameras = await availableCameras();
    setCamera();
    setState(() {});
  }

  void reHolds(){
    setState(() {
      _holdInfo = _callAPI();
    });
  }
  
  Future<List<Hold>> _callAPI() async {
    // API 호출 코드 작성
    Future<List<Hold>> tmp = Future.value(jsonString);
    return tmp;
  }

  void setCamera(){
    if (_cameras.isNotEmpty) {
      print("실행됨");
      _controller = CameraController(_cameras[0], ResolutionPreset.max, enableAudio: false, imageFormatGroup: ImageFormatGroup.yuv420);
      _initializeControllerFuture = _controller?.initialize().catchError((Object e) {
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
            builder: (context, snapshot){
              if(snapshot.connectionState == ConnectionState.done){
                return CameraPreview(_controller!);
              } else {
                return Center(child: CircularProgressIndicator(
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
              onTap: (){
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
              )
            )
          ),
        if (file != null)
          Stack(
            children: [
              Positioned.fill(
                child: Image(
                  image: XFileImage(file!)
                ),
              ),
              Container(
                alignment: Alignment(-0.9, 0.9),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    surfaceTintColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    )
                  ),
                  onPressed: (){
                    setState(() {
                      file = null;
                    });
                  },
                  child: Text("재촬영"),
                ),
              ),
              FutureBuilder<List<Hold>>(
                future: _holdInfo,
                builder: ((context, snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return SizedBox.shrink();
                  }
                  else if(snapshot.hasError){
                    return Center(child: Text('Error'));
                  }
                  else{
                    List<Hold> buttonHold = snapshot.data!;
                    return Stack(
                      children: [
                        for(Hold t in buttonHold)
                          Positioned(
                            // top: t.y2,
                            // left: t.x1,
                            // bottom: t.y1,
                            // right: t.x2,
                            top: 50,
                            left: 40,
                            width: 100,
                            height: 100,
                            child: SizedBox(
                              child: OutlinedButton(
                                onPressed: (){
                                  print("${t}버튼 실행");
                                },
                                child: Text(""),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: colorMap[t.color], width: 2.0),
                                ),
                              ),
                            )
                          )
                      ],
                    );
                  }
                }
              ),
            ),
          ]
        )
      ],
    );
  }
}
