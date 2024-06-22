// import 'package:flick_video_player/flick_video_player.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:wakelock/wakelock.dart';

// class VideoPlayerScreen extends StatefulWidget {
//   final String videoUrl;

//   const VideoPlayerScreen({super.key, required this.videoUrl});

//   @override
//   State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
// }

// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   FlickManager? flickManager;
//   VideoPlayerController? _videoPlayerController;
//   bool _isInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     print('Initializing video player with URL: ${widget.videoUrl}');

//     _videoPlayerController =
//         VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
//     _initializeVideoPlayer();

//     Wakelock.enable();
//   }

//   Future<void> _initializeVideoPlayer() async {
//     try {
//       await _videoPlayerController?.initialize();
//       print('Video initialized successfully');
//       setState(() {
//         flickManager = FlickManager(
//           videoPlayerController: _videoPlayerController!,
//         );
//         _isInitialized = true;
//       });
//     } catch (error) {
//       print('Error initializing video player: $error');
//     }
//   }

//   @override
//   void dispose() {
//     flickManager?.dispose();
//     Wakelock.disable();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0.0,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_rounded,
//             color: Colors.black,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       extendBodyBehindAppBar: true,
//       body: Center(
//         child: _isInitialized && flickManager != null
//             ? AspectRatio(
//                 aspectRatio: 9 / 16,
//                 child: FlickVideoPlayer(flickManager: flickManager!),
//               )
//             : const CircularProgressIndicator(),
//       ),
//     );
//   }
// }



// import 'package:flick_video_player/flick_video_player.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:wakelock/wakelock.dart';

// class VideoPlayerScreen extends StatefulWidget {
//   final String videoUrl;

//   const VideoPlayerScreen({super.key, required this.videoUrl});

//   @override
//   State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
// }

// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   late FlickManager flickManager;
//   late VideoPlayerController _videoPlayerController;
//   bool _isInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     print('Initializing video player with URL: ${widget.videoUrl}');

//     _videoPlayerController =
//         VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
//     print("debug1");
//     _videoPlayerController.addListener(() {
//       print("debug2");
//       print(_videoPlayerController.value.isInitialized);
//       if (_videoPlayerController.value.isInitialized && !_isInitialized) {
//         setState(() {
//           print("debug3");
//           _isInitialized = true;
//         });
//       }
//       print("debug4");
//     });

//     _videoPlayerController.initialize().then((_) {
//       print('initiallize!!!!');
//       setState(() {
//         print('initiallize Setstate!!!!');

//         flickManager = FlickManager(
//           videoPlayerController: _videoPlayerController,
//         );
//       });
//     }).catchError((error) {
//       print('Error initializing video player: $error');
//     });

//     Wakelock.enable();
//   }

//   @override
//   void dispose() {
//     flickManager.dispose();
//     Wakelock.disable();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0.0,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios_rounded,
//             color: Colors.black,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       extendBodyBehindAppBar: true,
//       body: Center(
//         child: _isInitialized
//             ? AspectRatio(
//                 aspectRatio: 9 / 16,
//                 child: FlickVideoPlayer(flickManager: flickManager),
//               )
//             : const CircularProgressIndicator(),
//       ),
//     );
//   }
// }


// import 'package:flick_video_player/flick_video_player.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:wakelock/wakelock.dart';

// class VideoPlayerScreen extends StatefulWidget {
//   final String videoUrl;

//   const VideoPlayerScreen({super.key, required this.videoUrl});

//   @override
//   State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
// }

// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   late FlickManager flickManager;

//   @override
//   void initState() {
//     super.initState();
//     flickManager = FlickManager(
//         videoPlayerController:
//             VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl)));
//     Wakelock.enable();
//   }

//   @override
//   void dispose() {
//     flickManager.dispose();
//     Wakelock.disable();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0.0,
//           leading: IconButton(
//             icon: const Icon(
//               Icons.arrow_back_ios_rounded,
//               color: Colors.black,
//             ),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//         ),
//         extendBodyBehindAppBar: true,
//         body: Center(
//           child: AspectRatio(
//             aspectRatio: 9 / 16,
//             child: FlickVideoPlayer(flickManager: flickManager),
//           ),
//         ));
//   }
// }
