import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'dart:ui';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
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
              )

            ],
          )
      ],
    );
  }
}
