import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  late List<CameraDescription> _cameras;

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
      _controller = CameraController(_cameras[0], ResolutionPreset.max, enableAudio: false);
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
      final XFile file = await _controller!.takePicture();
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
                Icons.camera_enhance,
                size: 70,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
