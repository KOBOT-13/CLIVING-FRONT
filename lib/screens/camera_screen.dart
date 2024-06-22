import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cross_file_image/cross_file_image.dart';
import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  late List<CameraDescription> _cameras;
  XFile? file;
  XFile? video;
  bool _buttonCheck = false;
  bool _recordingCheck = false;
  Future<Map<int, List<dynamic>>>? imageHoldInfos;
  int? key;
  int? first_image_id;

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
  
  Future<Map<int, List<dynamic>>> fetchData(var data) async {
    // 비동기 작업 시뮬레이션 (예: 네트워크 요청)
    // await Future.delayed(Duration(seconds: 1));
    Map<int, List<dynamic>> tmp = {};
    for(var d in data){
      tmp[d['index_number']] = [[d['x1'],d['y1'],d['x2'],d['y2']], true];
    }
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
      try{
        String apiAddress = dotenv.get("API_ADDRESS");
        print(apiAddress);
        final request = http.MultipartRequest('POST', Uri.parse("$apiAddress/v1/upload/image/"));
        request.files.add(await http.MultipartFile.fromPath('image', file!.path));
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

  Future<void> stopRecording() async {
    XFile? file = await _controller!.stopVideoRecording();
    setState(() {
      video = file;
    });
    // 영상 저장 API 실행
    try{
      String apiAddress = dotenv.get("API_ADDRESS");
      final request = http.MultipartRequest('POST', Uri.parse("$apiAddress/v1/video/"));
      request.files.add(await http.MultipartFile.fromPath('videofile', file.path));
      request.fields['video_color'] = "orange";
      request.fields['page_id'] = "240622";
      var response = await request.send();
      print(response.statusCode);
    } catch(e){
      print(e);
    }
  }

  Future<void> fetchTop() async{
    String apiAddress = dotenv.get("API_ADDRESS");
    final url = Uri.parse('$apiAddress/v1/hold/$first_image_id/$key/');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'is_top' : true,
      })
    );
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
                if(!_recordingCheck){
                  _takePicture();
                }
                else{
                  stopRecording();
                  _recordingCheck = false;
                }
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
          Center(
            child: SizedBox(
              width: screenSize.width,
              height: screenSize.height - 153,
              child: Stack(
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
                        )
                      ),
                      onPressed: (){
                        setState(() {
                          if(_buttonCheck){
                            if(!_recordingCheck){
                              _controller!.startVideoRecording();
                              _recordingCheck = true;
                              file = null;
                              fetchTop();
                            }
                          }
                          else{
                            Fluttertoast.showToast(
                              msg: "홀드를 선택해주세요.",
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Color.fromRGBO(0, 0, 0, 0.8),
                            );
                          }
                        });
                      },
                      child: Text("확정"),
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
                              return Stack(
                                children: [
                                  for(var t in buttonHold.entries)
                                    Positioned(
                                      top: t.value[0][0] / 2376 * constraints.maxWidth,
                                      left: t.value[0][1] / 4224 * constraints.maxHeight,
                                      child: SizedBox(
                                        width: (t.value[0][2] / 2376 * constraints.maxWidth) - (t.value[0][0] / 2376 * constraints.maxWidth),
                                        height: (t.value[0][3] / 4224 * constraints.maxHeight) - (t.value[0][1] / 4224 * constraints.maxHeight),
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
                                            side: MaterialStateProperty.resolveWith<BorderSide>(
                                              (states){
                                                return BorderSide(
                                                  color: colorMap["orange"],
                                                  width: 2.0,
                                                );
                                              }
                                            ),
                                            backgroundColor: MaterialStateProperty.resolveWith<Color>(
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
              ]
            ),
            ),
          )
      ],
    );
  }
}
