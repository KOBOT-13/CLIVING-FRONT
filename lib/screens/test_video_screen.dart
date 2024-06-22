// import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
// import 'package:wakelock/wakelock.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  double? aspectRatio;
  double progress = 0;
  Duration position = Duration.zero;
  Uri hardUri =
      Uri.parse('http://127.0.0.1:8000/media/clips/240620-01_1_10.mp4');

  @override
  void initState() {
    super.initState();
    print(isURLAccessible(widget.videoUrl));

    print('Initializing video player with URL: ${widget.videoUrl}');
    _videoPlayerController =
        // VideoPlayerController.asset('assets/videos/CallbackLogo.mp4')
        VideoPlayerController.networkUrl(hardUri)..initialize();

    _videoPlayerController.setPlaybackSpeed(1);
    _videoPlayerController.play();

    _videoPlayerController.addListener(() async {
      int max = _videoPlayerController.value.duration.inSeconds;
      setState(() {
        aspectRatio = _videoPlayerController.value.aspectRatio;
        position = _videoPlayerController.value.position;
        progress = (position.inSeconds / max * 100).isNaN
            ? 0
            : position.inSeconds / max * 100;
      });
    });
  }

  void seekTo(int value) {
    int add = position.inSeconds + value;

    _videoPlayerController.seekTo(Duration(seconds: add < 0 ? 0 : add));
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future<bool> isURLAccessible(String url) async {
    try {
      print('=======try======');
      final response = await http.get(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      print('URL 접근 오류: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          if (aspectRatio != null) ...[
            Center(
              child: Padding(
                padding: EdgeInsets.only(
                    bottom:
                        MediaQuery.of(context).padding.top + kToolbarHeight),
                child: AspectRatio(
                    aspectRatio: aspectRatio!,
                    child: VideoPlayer(_videoPlayerController)),
              ),
            ),
            Positioned(
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        seekTo(-10);
                      },
                      child: const SizedBox(
                        width: 30,
                        child: Icon(
                          Icons.replay_10_rounded,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        if (_videoPlayerController.value.isPlaying) {
                          _videoPlayerController.pause();
                        } else {
                          _videoPlayerController.play();
                        }
                      },
                      child: SizedBox(
                        width: 30,
                        child: Icon(
                          _videoPlayerController.value.isPlaying
                              ? Icons.stop
                              : Icons.play_arrow_rounded,
                          size: 32,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        seekTo(10);
                      },
                      child: const SizedBox(
                        width: 30,
                        child: Icon(
                          Icons.forward_10_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                        width: 30,
                        child: Text(
                          _videoPlayerController.value.position
                              .toString()
                              .substring(2, 7),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        )),
                    Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          width: MediaQuery.of(context).size.width - 206,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: const Color.fromRGBO(135, 135, 135, 1),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(seconds: 1),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          width: (MediaQuery.of(context).size.width - 206) *
                              (progress / 100),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: const Color.fromRGBO(215, 215, 215, 1),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        width: 30,
                        child: Text(
                          _videoPlayerController.value.duration
                              .toString()
                              .substring(2, 7),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        )),
                  ],
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}
