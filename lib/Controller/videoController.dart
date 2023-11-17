import 'package:chewie/chewie.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerService extends GetxController {
  late VideoPlayerController _videoController;
  late ChewieController chewieController;

  Future<void> initializeVideo(String videoUrl) async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
      videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
    );
    await _videoController.initialize();
    chewieController = ChewieController(
      videoPlayerController: _videoController,
    );
    //   ..initialize().then((value) => (){
    //   // _videoController.play();
    //   chewieController = ChewieController(
    //     videoPlayerController: _videoController,
    //   );
    // });


    print('IN INITIALIZE VIDEO $videoUrl');
    // _videoController = VideoController.network(videoUrl);
    // _videoController.addListener((){
    //   print(_videoController.value.position);
    // });
    // await _videoController.initialize();
    // await _videoController.play();
    // _videoController.seekTo()
  }


  VideoPlayerController get videoController => _videoController;

  void dispose() {
    _videoController.dispose();
  }
}

// import 'package:get/get.dart';
// import 'package:video_player/video_player.dart';
//
// class VideoPlayerService extends GetxController {
//   late VideoPlayerController _videoController;
//
//   Future<void> initializeVideo(String videoUrl) async {
//     _videoController = VideoPlayerController.networkUrl(
//       Uri.parse(videoUrl),
//       videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
//     )..initialize().then((value) => (){
//       // _videoController.play();
//     });
//     print('IN INITIALIZE VIDEO $videoUrl');
//     // _videoController = VideoController.network(videoUrl);
//     // _videoController.addListener((){
//     //   print(_videoController.value.position);
//     // });
//     // await _videoController.initialize();
//     // await _videoController.play();
//     // _videoController.seekTo()
//   }
//
//
//   VideoPlayerController get videoController => _videoController;
//
//   void dispose() {
//     _videoController.dispose();
//   }
// }




// import 'package:get/get.dart';
// import 'package:video_controls/video_controls.dart';
//
// class VideoPlayerService extends GetxService {
//   late VideoController _videoController;
//
//   Future<void> initializeVideo(String videoUrl) async {
//     // _videoController = VideoPlayerController.networkUrl(
//     //   Uri.parse(videoUrl),
//     //   videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
//     // );
//     print('IN INITIALIZE VIDEO $videoUrl');
//     _videoController = VideoController.network(videoUrl);
//     // _videoController.addListener((){
//     //   print(_videoController.value.position);
//     // });
//     await _videoController.initialize();
//     // _videoController.seekTo()
//   }
//
//
//   VideoController get videoController => _videoController;
//
//   void dispose() {
//     _videoController.dispose();
//   }
// }
