import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myanime/Controller/animeWatcherController.dart';
import 'package:myanime/Controller/homeController.dart';
import 'package:myanime/Controller/videoController.dart';
import 'package:myanime/Model/movie.dart';
import 'package:myanime/Shared/theme.dart';

import '../Controller/movieController.dart';
import '../Model/animedetails.dart';
import '../Shared/common.dart';

class MovieDetailsScreen extends StatefulWidget {
  final String animeKey;
  final String title;

  const MovieDetailsScreen(
      {super.key, required this.animeKey, required this.title});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  MovieModel? animeDetails;
  List<Episode> episodes = [];
  late AnimeWatcherController animeWatcherController;
  RxInt selectedIndex = 0.obs;
  RxBool loading = false.obs;
  final VideoPlayerService videoPlayerService = Get.put(VideoPlayerService());
  HomeController homeController = Get.put(HomeController());
  MovieController movieController = Get.put(MovieController());
  // var animeData;
  RxBool hasData = false.obs;
  Icon bookmarkIcon = const Icon(Icons.bookmark_border);

  @override
  void initState() {
    super.initState();
    animeWatcherController = Get.put(AnimeWatcherController());
    animeWatcherController.setTitle(widget.title);
    print('search query in movies ${movieController.query}');
    // animeWatcherController.retrieveData();
  }

  @override
  Future<void> didChangeDependencies() async {
    animeDetails = await fetchAnimeDetails(widget.animeKey);
    await animeWatcherController.init();
    super.didChangeDependencies();
  }

  Future<MovieModel> fetchAnimeDetails(String key) async {
    print('${Common.movieUrls[movieController.selectedServer.value]}info?id=$key');
    final response = await Dio().get(
        '${Common.movieUrls[movieController.selectedServer.value]}info?id=$key');

    print('anime details');

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = response.data;
      hasData.value = true;
      // return AnimeDetails.fromJson(json);
      return MovieModel.fromJson(json);
    } else {
      throw Exception('Failed to load anime details');
    }
  }

  Future<void> fetchVideoUrl(String videoId) async {
    // hasData.value = true;
    // final response = await Dio().get('https://my-anime.onrender.com/vidcdn/watch/$videoId');
    loading.value = true;
    print(
        'query ${Common.movieUrls[movieController.selectedServer.value]}watch');
    final response = await Dio().get(
        '${Common.movieUrls[movieController.selectedServer.value]}watch',queryParameters: {"episodeId": videoId,"mediaId": widget.animeKey});
    print('anime key ${widget.title} id: $videoId');
    print(
        'in retrive ${animeWatcherController.animeData.containsKey(videoId)} ${animeWatcherController.animeData[videoId]}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = response.data;
      final List<dynamic> sources = responseData['sources'];
      print('anime key ${widget.title}');
      if (sources.isNotEmpty) {
        final String videoUrl =
            sources[0]['url']; // Assuming the first source is the video URL
        print('video url: $videoUrl');
        // try{
        //   if(videoPlayerService.videoController.value.isInitialized)  await videoPlayerService.videoController.dispose();
        // }catch(e){
        //   print(e);
        // }
        // if(videoPlayerService.initialized){
        //   videoPlayerService.videoController.dataSource = videoUrl;
        // }
        await videoPlayerService.initializeVideo(videoUrl);
        // await videoPlayerService.initializeVideo('http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4');
        if (animeWatcherController.animeData.containsKey(videoId)) {
          print(
              'seeked to ${Duration(seconds: int.parse(animeWatcherController.animeData[videoId]!))}');
          await videoPlayerService.videoController.seekTo(Duration(
              seconds: int.parse(animeWatcherController.animeData[videoId]!)));
        }
        loading.value = false;
        videoPlayerService.playingUrl.value = videoUrl;
        // for (var items in sources) {
        //   print('have link');
        //   // videoPlayerService.urls.add(items['url']);
        //   videoPlayerService.urls[items['quality']] = items['url'];
        // }
        // animeWatcherController.storeData( videoId, Duration.zero);
        // videoPlayerService.videoController.play();
        print('current route ${Get.currentRoute} previous route ${Get.previousRoute}');
        if(Get.currentRoute == '/') {
          videoPlayerService.videoController.dispose();
          videoPlayerService.chewieController.dispose();
          return;
        }
        videoPlayerService.chewieController.play();
        // videoPlayerService.chewieController.additionalOptions(context){
        //   return <OptionItem>[
        //     OptionItem(
        //       onTap: () async {
        //         await videoPlayerService.videoController.pause();
        //         videoPlayerService.chewieController.pause();
        //       },
        //       iconData: Icons.pause,
        //       title: 'Pause',
        //     ),
        //     OptionItem(
        //       onTap: () async {
        //         await videoPlayerService.videoController.play();
        //         videoPlayerService.chewieController.play();
        // };

        // videoPlayerService.chewieController.videoPlayerController;

        // _controller.changeSource(source: VideoSource(video: VideoPlayerController.networkUrl(Uri.parse(playingUrl.value))), name: 'Anime');

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
    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                widget.title,
                style: myTextTheme.displayMedium,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    hasData.value = true;
                    if (homeController.watchList.contains(
                        '${widget.animeKey},${widget.title},${animeDetails!.image}')) {
                      homeController.watchList.removeWhere((element) =>
                          element.contains(
                              '${widget.animeKey},${widget.title},${animeDetails!.image},movie'));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Removed from watchlist',
                            style: myTextTheme.titleMedium),
                      ));
                      homeController.storeWatchlist();
                      return;
                    }
                    homeController.watchList.add(
                        '${widget.animeKey},${widget.title},${animeDetails!.image},movie');
                    homeController.storeWatchlist();
                    print(
                        'added ${widget.animeKey},${widget.title},${animeDetails!.image}');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        'Added to watchlist',
                        style: myTextTheme.titleMedium,
                      ),
                    ));
                  },
                  // icon: Obx(() => hasData.value ?(homeController.watchList.contains('${widget.animeKey},${widget.title},${animeDetails!.image}') ? const Icon(Icons.bookmark) : const Icon(Icons.bookmark_outline)):const Icon(Icons.bookmark_outline),
                  icon: Obx(
                    () => hasData.value
                        ? (homeController.watchList.contains(
                                '${widget.animeKey},${widget.title},${animeDetails!.image}')
                            ? const Icon(Icons.bookmark)
                            : const Icon(Icons.bookmark_outline))
                        : const Icon(Icons.bookmark_outline),
                  ),
                )
              ],
            ),
            body: Obx(() {
              if (!hasData.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                // animeData = animeDetails!;
                // if(animeDetails!.episodes.length > 100 ){
                //   episodes = animeDetails!.episodes.sublist(0, 100);
                // }
                print('desc ${animeDetails!.description}');
                if (!animeWatcherController.recentWatches.contains(
                    '${widget.animeKey},${widget.title},${animeDetails!.image},movie'))
                  animeWatcherController.recentWatches.add(
                      '${widget.animeKey},${widget.title},${animeDetails!.image},movie');
                if (videoPlayerService.playingUrl.value == '') {
                  try {
                    String key = animeWatcherController.getLatestEp();
                    print('key $key');
                    if (selectedIndex.value == 0)
                      selectedIndex.value = animeDetails!.episodes
                          .indexWhere((element) => element.id == key);
                    // videoPlayerService.playingUrl.value = animeDetails!.episodes[selectedIndex.value].url;
                    // videoPlayerService.playingUrl.value = 'not';
                  } catch (e) {
                    print('in catch');
                    selectedIndex.value = 0;
                    // videoPlayerService.playingUrl.value = animeDetails!.episodes[selectedIndex.value].url;
                    // fetchVideoUrl(animeDetails!.episodes[selectedIndex.value].id);
                  }

                  print('selected ${selectedIndex.value}');
                  // print('fetching ${animeDetails!.episodes.length}');
                  // if(animeDetails!.totalEpisodes != '0') fetchVideoUrl(animeDetails!.episodes.last.id);

                  if (selectedIndex.value == 0) {
                    selectedIndex.value = animeDetails!.episodes.length - 1;
                    // videoPlayerService.playingUrl.value = animeDetails!.episodes[selectedIndex.value].url;
                    fetchVideoUrl(animeDetails!
                        .episodes[selectedIndex.value].id);
                    // videoPlayerService.playingUrl.value = animeDetails!.episodes[selectedIndex.value].url;
                    // selectedIndex.value = animeDetails!.episodes.length - 1;
                  } else
                    fetchVideoUrl(animeDetails!
                        .episodes[selectedIndex.value].id);
                }
                print('playing url ${videoPlayerService.playingUrl.value}');

                // if(videoPlayerService.playingUrl.isNotEmpty) fetchVideoUrl(videoPlayerService.playingUrl.value);
                // Use animeDetails! to display details on the screen
                return Scaffold(
                  body: SizedBox(
                    child: SingleChildScrollView(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                              () {
                            if (videoPlayerService.playingUrl.value != '') {
                              // return SizedBox(width: Get.width,height: Get.height / 4,child: VideoPlayer(videoPlayerService.videoController),);
                              return Stack(
                                children: [
                                  FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: Get.width,
                                      height: Get.height / 3.6,
                                      child: Chewie(
                                        controller:
                                        videoPlayerService.chewieController,
                                      ),
                                    ),
                                  ),
                                  loading.value
                                      ? SizedBox(
                                    height: Get.height / 3,
                                    width: double.infinity,
                                    child: const Center(
                                      heightFactor: 2,
                                      widthFactor: 2,
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                      : const SizedBox(),
                                ],
                              );
                              // return SizedBox(width: Get.width,height: Get.height / 4,child: VideoPlayer(videoPlayerService.videoController),);
                            } else {
                              print('currently ${loading.value}');
                              return Stack(
                                children: [
                                  SizedBox(
                                    height: Get.height / 3,
                                    width: double.infinity,
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: animeDetails!.image,
                                      placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) {
                                        print("Error loading image: $error");
                                        return const Icon(Icons.error);
                                      },
                                    ),
                                  ),
                                  loading.value
                                      ? SizedBox(
                                    height: Get.height / 3,
                                    width: double.infinity,
                                    child: const Center(
                                      heightFactor: 2,
                                      widthFactor: 2,
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                      : const SizedBox(),
                                ],
                              );
                            }
                          },
                        ),

                        // VideoViewer(
                        // controller: _controller,
                        // autoPlay: true,
                        // source: {
                        // "WebVTT Caption":
                        // VideoSource(video: VideoPlayerController.networkUrl(
                        // videoPlayerOptions: VideoPlayerOptions(allowBackgroundPlayback: true),
                        // //This video has a problem when end
                        // Uri.parse(playingUrl.value)))}),
                        const SizedBox(width: 15,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 5,),
                            Text(
                              animeDetails!.title,
                              style: myTextTheme.titleLarge,
                            )
                          ],
                        ),
                        // Text(animeDetails!.description,style: myTextTheme.bodyMedium,),

                        // ExpandableDescription(
                        //   description: animeDetails!.description,
                        // ),
                        const SizedBox(height: 10,),
                        if(animeDetails!.episodes.length > 1)Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: SizedBox(
                              height: Get.height / 3,
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7, // 5 containers in a row
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                ),
                                itemCount: animeDetails!.episodes.length,
                                itemBuilder: (context, index) {
                                  final episode =
                                      animeDetails!.episodes[index];
                                  return GestureDetector(
                                      onTap: () async {
                                        // Get.to(()=> AnimePlayerScreen(videoId: episode.id));
                                        Duration? pos = await videoPlayerService
                                            .videoController.position;
                                        print(
                                            'anime id ${animeDetails!.episodes[selectedIndex.value].id}, duration: ${pos!.inSeconds.toString()}');
                                        animeWatcherController.storeData(
                                            animeDetails!
                                                .episodes[
                                                    selectedIndex.value]
                                                .id,
                                            pos.inSeconds.toString());
                                        // animeWatcherController.storeData(animeDetails!.episodesList.where((element) => element.episodeNum == selectedEpIndex.value.toString()).first.episodeId,
                                        //     // animeWatcherController.storeData(animeDetails!.episodesList[selectedEpIndex.value].episodeId,
                                        //     pos.inSeconds.toString());
                                        selectedIndex.value = index;
                                        videoPlayerService.playingUrl.value =
                                            '';
                                        print(
                                            'anime id selected index $selectedIndex');
                                        videoPlayerService.chewieController
                                            .pause();
                                        videoPlayerService.chewieController
                                            .dispose();
                                        videoPlayerService.videoController
                                            .dispose();
                                        videoPlayerService.urls.clear();
                                        videoPlayerService.playingUrl.value =
                                            episode.url;
                                        fetchVideoUrl(episode.id);
                                        // videoPlayerService.videoController.pause();
                                      },
                                      child: Stack(
                                        children: [
                                          Align(
                                            alignment: Alignment.center,
                                            child: Obx(
                                              () => Container(
                                                  height: 50,
                                                  width: 50,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: selectedIndex
                                                              .value ==
                                                              index
                                                              ? Colors.orangeAccent
                                                              .shade400
                                                              : (animeWatcherController
                                                              .animeData
                                                              .containsKey(
                                                              episode
                                                                  .id))
                                                              ? Colors.green
                                                              .shade300
                                                              .withOpacity(
                                                              0.5)
                                                              : Colors
                                                              .red.shade400
                                                              .withOpacity(
                                                              0.5)),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      color: selectedIndex
                                                                  .value ==
                                                              index
                                                          ? Colors.orangeAccent
                                                              .shade200
                                                          : (animeWatcherController
                                                                  .animeData
                                                                  .containsKey(
                                                                      episode
                                                                          .id))
                                                              ? Colors.green
                                                                  .shade100
                                                                  .withOpacity(
                                                                      0.5)
                                                              : Colors
                                                                  .red.shade200
                                                                  .withOpacity(
                                                                      0.5))),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              '$index',
                                              style: const TextStyle(
                                                  fontSize: 16.0,
                                                  overflow: TextOverflow.fade),
                                            ),
                                          ),
                                        ],
                                      ));
                                },
                              )
                              // episodes.isEmpty?:GridView.builder(
                              //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              //     crossAxisCount: 7, // 5 containers in a row
                              //     crossAxisSpacing: 8.0,
                              //     mainAxisSpacing: 8.0,
                              //   ),
                              //   itemCount: episodes.length,
                              //   itemBuilder: (context, index) {
                              //     final episode = episodes[index];
                              //     return GestureDetector(onTap: () async {
                              //       // Get.to(()=> AnimePlayerScreen(videoId: episode.id));
                              //       Duration? pos = await videoPlayerService.videoController.position;
                              //       print('anime id ${animeDetails!.episodes[selectedIndex.value].id}, duration: ${pos!.inSeconds.toString()}');
                              //       animeWatcherController.storeData(animeDetails!.episodes[selectedIndex.value].id, pos.inSeconds.toString());
                              //       selectedIndex.value = index;
                              //       videoPlayerService.playingUrl.value = '';
                              //       print('anime id selected index $selectedIndex');
                              //       videoPlayerService.chewieController.pause();
                              //       videoPlayerService.chewieController.dispose();
                              //       videoPlayerService.videoController.dispose();
                              //       videoPlayerService.urls.clear();
                              //       videoPlayerService.playingUrl.value = episode.url;
                              //       fetchVideoUrl(episode.id);
                              //       // videoPlayerService.videoController.pause();
                              //     },
                              //         child: Stack(
                              //           children: [
                              //             Align(alignment: Alignment.center,child: Obx(() => Container(
                              //                 height: 50,width: 50,
                              //                 decoration: BoxDecoration(
                              //                     border: Border.all(color: Colors.black),
                              //                     borderRadius: BorderRadius.circular(10.0),
                              //                     color: selectedIndex.value == index? Colors.orangeAccent.shade200:(animeWatcherController.animeData.containsKey(episode.id))?Colors.green.shade100.withOpacity(0.5):Colors.red.shade200.withOpacity(0.5)
                              //                 )),),),
                              //             Align(
                              //               alignment: Alignment.center,
                              //               child: Text(
                              //                 episode.episodeNum,
                              //                 style: const TextStyle(fontSize: 16.0,overflow: TextOverflow.fade),
                              //               ),
                              //             ),
                              //           ],));
                              //   },)
                              ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    )),
                  ),
                  // bottomNavigationBar: animeDetails!.status == 'Upcoming'
                  //     ? Row(
                  //         mainAxisAlignment: MainAxisAlignment.center,
                  //         children: [
                  //           Text(
                  //             'Upcoming',
                  //             style: myTextTheme.titleMedium,
                  //           )
                  //         ],
                  //       )
                  //     : const SizedBox(),
                );
              }
            })),
        onWillPop: () async {
          try {
            Duration? pos = await videoPlayerService.videoController.position;
            print(
                'in dispose id:${animeDetails!.episodes[selectedIndex.value].id}, pos: ${pos!.inSeconds.toString()}');
            animeWatcherController.storeData(
                animeDetails!.episodes[selectedIndex.value].id,
                pos.inSeconds.toString());
            await animeWatcherController.onClose();
            videoPlayerService.chewieController.dispose();
            videoPlayerService.dispose();
            return true;
          } catch (e) {
            print('caught stored data closed super failed $e');
            return true;
          }
        });
  }

// @override
// Future<void> dispose() async {
//   try{
//     super.dispose();
//   }catch(e){
//     print('caught stored data closed super failed $e');
//   }
//   Duration? pos = await videoPlayerService.videoController.position;
//   print('in dispose id:${animeDetails!.episodes[selectedIndex.value].id}, pos: ${pos!.inSeconds.toString()}');
//   animeWatcherController.storeData( animeDetails!.episodes[selectedIndex.value].id,pos.inSeconds.toString());
//   await animeWatcherController.onClose();
//   videoPlayerService.chewieController.dispose();
//   videoPlayerService.dispose();
// }
}
