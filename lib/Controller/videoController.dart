
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerService extends GetxController {
  late VideoPlayerController _videoController;
  late ChewieController chewieController;
  RxString playingUrl = ''.obs;
  // List<String> urls = [];
  Map<String,String> urls = {};
  Duration? position;

  Future<void> initializeVideo(String videoUrl) async {
    // if(videoUrl == playingUrl.value) return;
    print('IN INITIALIZE VIDEO called $videoUrl urio parsed');
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
      videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
    );
    print('IN INITIALIZE VIDEO $videoUrl urio parsed');
    await _videoController.initialize();
    print('IN INITIALIZE VIDEO $videoUrl controller initialized');
    chewieController = ChewieController(
      videoPlayerController: _videoController,
      draggableProgressBar: true,
      autoInitialize: true,
      additionalOptions: (context) {
        return <OptionItem>[
          if(urls.isNotEmpty) OptionItem(
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SizedBox(height: 250,child: ListView(
                    children: urls.entries.map((entry) {
                      if(!entry.key.contains('p') || entry.key == 'backup')return const SizedBox();
                      return ListTile(
                        title: Text(entry.key),
                        // titleTextStyle: myTextTheme.bodyMedium,
                        tileColor: playingUrl.value == entry.value ? Colors.grey[300] : null,
                        onTap: () async {
                          // Change the playing URL to the selected quality's URL
                          changeQuality(entry.value);
                          Navigator.pop(context); // Close the bottom sheet
                        },
                      );
                    }).toList(),
                  ),);
                },
              );
            },
            iconData: Icons.hd,
            title: 'Quality',
          ) ,
        ];
      },
      // autoInitialize: true,
      // looping: false,
      // autoPlay: false,
    );
    //   ..initialize().then((value) => (){
    //   // _videoController.play();
    //   chewieController = ChewieController(
    //     videoPlayerController: _videoController,
    //   );
    // });


    print('IN INITIALIZE VIDEO completed $videoUrl');
    // _videoController = VideoController.network(videoUrl);
    // _videoController.addListener((){
    //   print(_videoController.value.position);
    // });
    // await _videoController.initialize();
    // await _videoController.play();
    // _videoController.seekTo()
  }

  Future<void> changeQuality(String newUrl) async {
    // playingUrl.value = 'temp';
    if(videoController.value.isInitialized) {
      position = await chewieController.videoPlayerController.position;
      chewieController.pause(); // Pause the video before changing the quality
      _videoController.dispose();
      chewieController.dispose();
    }
    print('playing new before init $newUrl');
    try{
      await initializeVideo(newUrl);
      playingUrl.value = newUrl;
    }
    catch(e){
      await initializeVideo(playingUrl.value);
      String temp = playingUrl.value;
      playingUrl.value = newUrl;
      playingUrl.value  = temp;
      print(e);
    }
    print('playing new inited $newUrl');
    chewieController.videoPlayerController.seekTo(position??Duration.zero);
    chewieController.play();
    print('playing new end $playingUrl');
    // _videoController = VideoPlayerController.networkUrl(
    //   Uri.parse(newUrl),
    //   videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
    // );
    // _videoController.initialize().then((value) => (){
    //   _videoController.seekTo(position?? Duration.zero);
    //   _videoController.play();// Start playing the new quality
    //   print('playing new');
    // });
    // _videoController.play();
  }


  VideoPlayerController get videoController => _videoController;

  @override
  void dispose() {
    super.dispose();
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
