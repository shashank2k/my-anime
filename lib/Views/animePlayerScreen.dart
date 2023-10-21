import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_viewer/video_viewer.dart';
import 'package:dio/dio.dart';

class AnimePlayerScreen extends StatefulWidget {
  final String videoId;

  const AnimePlayerScreen({required this.videoId, Key? key}) : super(key: key);

  @override
  State<AnimePlayerScreen> createState() => _AnimePlayerScreenState();
}

class _AnimePlayerScreenState extends State<AnimePlayerScreen> {
  RxString playingUrl = ''.obs;
  List<String> urls = [];

  @override
  void initState() {
    super.initState();
    // Fetch the video URL using the provided videoId
    fetchVideoUrl(widget.videoId);
  }

  Future<void> fetchVideoUrl(String videoId) async {
    final response =
        await Dio().get('https://my-anime.onrender.com/vidcdn/watch/$videoId');
    print('https://my-anime.onrender.com/vidcdn/watch/$videoId');

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = response.data;
      final List<dynamic> sources = responseData['sources'];

      if (sources.isNotEmpty) {
        final String videoUrl =
            sources[0]['file']; // Assuming the first source is the video URL
        playingUrl.value = videoUrl;
        for (var items in sources) {
          urls.add(items['file']);
        }
        return;
      } else {
        throw Exception('No video sources found in the response');
      }
    } else {
      throw Exception('Failed to fetch video URL');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Anime Player'),
        ),
        body: Column(
          children: [
            Obx(
              () => playingUrl.value != ''
                  ? VideoViewer(
                      source: {
                        "WebVTT Caption":
                            VideoSource(video: VideoPlayerController.networkUrl(
                                //This video has a problem when end
                                Uri.parse(playingUrl.value)))
                      },
                    )
                  : const Text('Nothing to play'),
            ),
            // GestureDetector(
            //     onTap: () {
            //       Get.to(() => AnimePlayerScreen(videoId: episode.episodeId));
            //     },
            //     child: Stack(
            //       children: [
            //         Align(
            //           alignment: Alignment.center,
            //           child: Container(
            //               height: 50,
            //               width: 50,
            //               decoration: BoxDecoration(
            //                 border: Border.all(color: Colors.black),
            //                 borderRadius: BorderRadius.circular(10.0),
            //               )),
            //         ),
            //         Align(
            //           alignment: Alignment.center,
            //           child: Text(
            //             episode.episodeNum,
            //             style: const TextStyle(
            //                 fontSize: 16.0, overflow: TextOverflow.fade),
            //           ),
            //         ),
            //       ],
            //     )),
          ],
        ));
  }

  @override
  void dispose() {
    super.dispose();
  }
}
