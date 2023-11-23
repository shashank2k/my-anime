import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myanime/Controller/animeWatcherController.dart';
import 'package:myanime/Controller/homeController.dart';
import 'package:myanime/Controller/videoController.dart';
import 'package:myanime/Shared/theme.dart';
import '../Model/animedetails.dart';
import '../Shared/common.dart';

class AnimeDetailsScreen extends StatefulWidget {
  final String animeKey;
  final String animeTitle;

  const AnimeDetailsScreen(
      {super.key, required this.animeKey, required this.animeTitle});

  @override
  State<AnimeDetailsScreen> createState() => _AnimeDetailsScreenState();
}

class _AnimeDetailsScreenState extends State<AnimeDetailsScreen> {
  AnimeDetails? animeDetails;
  List<Episode> episodesList = [];
  late AnimeWatcherController animeWatcherController;
  RxInt selectedEpIndex = 0001.obs;
  RxInt selectedServerIndex = 0.obs;
  final VideoPlayerService videoPlayerService = Get.put(VideoPlayerService());
  HomeController homeController = Get.put(HomeController());
  // var animeData;
  RxBool hasData = false.obs;
  RxBool loading = false.obs;
  Icon bookmarkIcon = const Icon(Icons.bookmark_border);
  Map<String, String> availableServers = {};
  List<String> servers = [];

  @override
  void initState() {
    super.initState();
    animeWatcherController = Get.put(AnimeWatcherController());
    animeWatcherController.setTitle(widget.animeTitle);
    // animeWatcherController.retrieveData();
  }

  @override
  Future<void> didChangeDependencies() async {
    await animeWatcherController.init();
    animeDetails = await fetchAnimeDetails(widget.animeKey);
    super.didChangeDependencies();
  }

  Future<AnimeDetails> fetchAnimeDetails(String key) async {
    final response = await Dio().get('${Common.baseGogoUrl}info/$key');
    print('${Common.baseGogoUrl}info/$key');
    print('anime key ${widget.animeTitle} id: $key');
    print(
        'in retrive ${animeWatcherController.animeData.containsKey(key)} ${animeWatcherController.animeData[key]}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = response.data;
      hasData.value = true;
      return AnimeDetails.fromJson(json);
    } else {
      throw Exception('Failed to load anime details');
    }
  }

  Future<void> fetchVideoUrl(String videoId) async {
    // hasData.value = true;
    // final response = await Dio().get('https://my-anime.onrender.com/vidcdn/watch/$videoId');
    loading.value = true;
    final response = await Dio().get('${Common.baseGogoUrl}watch/$videoId');
    print('${Common.baseGogoUrl}watch/$videoId');
    print('anime key ${widget.animeTitle} id: $videoId');
    print(
        'in retrive ${animeWatcherController.animeData.containsKey(videoId)} ${animeWatcherController.animeData[videoId]}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = response.data;
      final List<dynamic> sources = responseData['sources'];
      print('anime key ${widget.animeTitle}');
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
        videoPlayerService.playingUrl.value = videoUrl;
        loading.value = false;
        for (var items in sources) {
          print('have link');
          // videoPlayerService.urls.add(items['url']);
          videoPlayerService.urls[items['quality']] = items['url'];
        }
        // animeWatcherController.storeData( videoId, Duration.zero);
        // videoPlayerService.videoController.play();
        videoPlayerService.chewieController.play();
        if(availableServers.isEmpty)fetchAvailableServers(videoId);
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

  Future<void> fetchAvailableServers(String videoId) async {
    final response = await Dio().get('${Common.baseGogoUrl}servers/$videoId');
    print('${Common.baseGogoUrl}watch/$videoId');
    print('anime key ${widget.animeTitle} id: $videoId');
    print(
        'in retrieve ${animeWatcherController.animeData.containsKey(videoId)} ${animeWatcherController.animeData[videoId]}');

    if (response.statusCode == 200) {
      print('got servers $availableServers');
      for (final entry in response.data) {
        final String name = entry['name'] ?? '';
        final String url = entry['url'] ?? '';
        availableServers[name] = url;
      }
      selectedServerIndex.value = 0;
      // loading.value = false;
      servers = availableServers.keys.toList();
    } else {
      // Handle error cases
      print('Failed to fetch servers. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                widget.animeTitle,
                style: myTextTheme.displayMedium,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    hasData.value = true;
                    if (homeController.watchList.contains(
                        '${widget.animeKey},${widget.animeTitle},${animeDetails!.animeImg}')) {
                      homeController.watchList.removeWhere((element) =>
                          element.contains(
                              '${widget.animeKey},${widget.animeTitle},${animeDetails!.animeImg}'));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Removed from watchlist',
                            style: myTextTheme.titleMedium),
                      ));
                      return;
                    }
                    homeController.watchList.add(
                        '${widget.animeKey},${widget.animeTitle},${animeDetails!.animeImg}');
                    print(
                        'added ${widget.animeKey},${widget.animeTitle},${animeDetails!.animeImg}');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        'Added to watchlist',
                        style: myTextTheme.titleMedium,
                      ),
                    ));
                  },
                  // icon: Obx(() => hasData.value ?(homeController.watchList.contains('${widget.animeKey},${widget.animeTitle},${animeDetails!.animeImg}') ? const Icon(Icons.bookmark) : const Icon(Icons.bookmark_outline)):const Icon(Icons.bookmark_outline),
                  icon: Obx(
                    () => hasData.value
                        ? (homeController.watchList.contains(
                                '${widget.animeKey},${widget.animeTitle},${animeDetails!.animeImg}')
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
                // if(animeDetails!.episodesList.length > 100 ){
                //   episodesList = animeDetails!.episodesList.sublist(0, 100);
                // }
                print('desc ${animeDetails!.description}');
                if (!animeWatcherController.recentWatches.contains(
                    '${widget.animeKey},${widget.animeTitle},${animeDetails!.animeImg}'))
                  animeWatcherController.recentWatches.add(
                      '${widget.animeKey},${widget.animeTitle},${animeDetails!.animeImg}');
                if (videoPlayerService.playingUrl.value == '') {
                  try {
                    String key = animeWatcherController.getLatestEp();
                    print('key $key');
                    if (selectedEpIndex.value == 0)
                      selectedEpIndex.value = animeDetails!.episodesList
                          .indexWhere((element) => element.episodeId == key);
                    // videoPlayerService.playingUrl.value = animeDetails!.episodesList[selectedIndex.value].episodeUrl;
                    // videoPlayerService.playingUrl.value = 'not';
                  } catch (e) {
                    print('in catch');
                    selectedEpIndex.value = 0;
                    // videoPlayerService.playingUrl.value = animeDetails!.episodesList[selectedIndex.value].episodeUrl;
                    // fetchVideoUrl(animeDetails!.episodesList[selectedIndex.value].episodeId);
                  }

                  print('selected ${selectedEpIndex.value}');
                  // print('fetching ${animeDetails!.episodesList.length}');
                  // if(animeDetails!.totalEpisodes != '0') fetchVideoUrl(animeDetails!.episodesList.last.episodeId);

                  if (selectedEpIndex.value == 0) {
                    selectedEpIndex.value =
                        animeDetails!.episodesList.length - 1;
                    // videoPlayerService.playingUrl.value = animeDetails!.episodesList[selectedIndex.value].episodeUrl;
                    fetchVideoUrl(animeDetails!
                        .episodesList[selectedEpIndex.value].episodeId);
                    // videoPlayerService.playingUrl.value = animeDetails!.episodesList[selectedIndex.value].episodeUrl;
                    // selectedIndex.value = animeDetails!.episodesList.length - 1;
                  } else
                    fetchVideoUrl(animeDetails!
                        .episodesList[selectedEpIndex.value].episodeId);
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
                                      imageUrl: animeDetails!.animeImg,
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

                        const SizedBox(height: 10,),

                        Obx(() => (selectedServerIndex.value != 0001 &&
                                availableServers.isNotEmpty)
                            ? SizedBox(
                                height: 35,
                                child: ListView.builder(
                                    itemCount: availableServers.length,
                                    scrollDirection: Axis.horizontal,
                                    clipBehavior: Clip.none,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                          onTap: () async {

                                            String url = availableServers.values
                                                .elementAt(index);
                                            selectedServerIndex.value = index;
                                            print('url in server $url now server value is $selectedServerIndex');
                                            // videoPlayerService.chewieController.pause();
                                            // videoPlayerService
                                            //     .playingUrl.value = '';
                                            videoPlayerService.changeQuality(url);
                                            // fetchVideoUrl(url);
                                          },
                                          child:
                                          Padding(padding: const EdgeInsets.symmetric(horizontal: 5.0),child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                    Colors.black),
                                                borderRadius:
                                                BorderRadius.circular(
                                                    10.0),
                                                color: selectedServerIndex
                                                    .value ==
                                                    index
                                                    ? Colors.green
                                                    .shade100
                                                    .withOpacity(
                                                    0.5)
                                                    : Colors
                                                    .red.shade200
                                                    .withOpacity(
                                                    0.5)),
                                            child: Padding(padding: const EdgeInsets.all(5),child: Text(
                                              servers[index],
                                              style: const TextStyle(
                                                  fontSize: 16.0,
                                                  overflow:
                                                  TextOverflow.fade),
                                            ),),
                                          ),)
                                          // Stack(
                                          //   children: [
                                          //     Align(
                                          //       alignment: Alignment.center,
                                          //       child: Obx(
                                          //         () => Container(
                                          //             height: 50,
                                          //             width: 50,
                                          //             decoration: BoxDecoration(
                                          //                 border: Border.all(
                                          //                     color:
                                          //                         Colors.black),
                                          //                 borderRadius:
                                          //                     BorderRadius.circular(
                                          //                         10.0),
                                          //                 color: selectedServerIndex
                                          //                             .value ==
                                          //                         index
                                          //                     ? Colors.green
                                          //                         .shade100
                                          //                         .withOpacity(
                                          //                             0.5)
                                          //                     : Colors
                                          //                         .red.shade200
                                          //                         .withOpacity(
                                          //                             0.5))),
                                          //       ),
                                          //     ),
                                          //     Align(
                                          //       alignment: Alignment.center,
                                          //       child: Text(
                                          //         servers[index],
                                          //         style: const TextStyle(
                                          //             fontSize: 16.0,
                                          //             overflow:
                                          //                 TextOverflow.fade),
                                          //       ),
                                          //     ),
                                          //   ],
                                          // )
                                      );
                                    }))
                            : const SizedBox()),

                        const SizedBox(height: 10,),

                        Row(
                          children: [
                            SizedBox(width: 5,),
                            Text(
                              animeDetails!.animeTitle,
                              style: myTextTheme.titleLarge,
                            ),
                          ],
                        ),
                        // Text(animeDetails!.description,style: myTextTheme.bodyMedium,),

                    ExpandableDescription(
                      description: animeDetails!.description,
                    ),

                        // ExpansionTile(
                        //   title: Text(
                        //     'Anime Description',
                        //     style: myTextTheme.bodyLarge,
                        //   ),
                        //   children: <Widget>[
                        //     Text(
                        //       animeDetails!.description,
                        //       style: myTextTheme.bodyMedium,
                        //     )
                        //   ],
                        // ),

                        const SizedBox(
                          height: 15,
                        ),

                        Padding(
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
                                itemCount: animeDetails!.episodesList.length,
                                itemBuilder: (context, index) {
                                  final episode =
                                      animeDetails!.episodesList[index];
                                  return GestureDetector(
                                      onTap: () async {
                                        // Get.to(()=> AnimePlayerScreen(videoId: episode.episodeId));
                                        Duration? pos = await videoPlayerService
                                            .videoController.position;
                                        print(
                                            'anime id ${animeDetails!.episodesList[selectedEpIndex.value].episodeId}, duration: ${pos!.inSeconds.toString()}');
                                        animeWatcherController.storeData(
                                            animeDetails!
                                                .episodesList[
                                                    selectedEpIndex.value]
                                                .episodeId,
                                            pos.inSeconds.toString());
                                        selectedEpIndex.value = index;
                                        videoPlayerService.playingUrl.value =
                                            '';
                                        print(
                                            'anime id selected index $selectedEpIndex');
                                        videoPlayerService.chewieController
                                            .pause();
                                        videoPlayerService.chewieController
                                            .dispose();
                                        videoPlayerService.videoController
                                            .dispose();
                                        videoPlayerService.urls.clear();
                                        videoPlayerService.playingUrl.value =
                                            episode.episodeUrl;
                                        fetchVideoUrl(episode.episodeId);
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
                                                          color: Colors.black),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      color: selectedEpIndex
                                                                  .value ==
                                                              index
                                                          ? Colors.orangeAccent
                                                              .shade200
                                                          : (animeWatcherController
                                                                  .animeData
                                                                  .containsKey(
                                                                      episode
                                                                          .episodeId))
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
                                              episode.episodeNum,
                                              style: const TextStyle(
                                                  fontSize: 16.0,
                                                  overflow: TextOverflow.fade),
                                            ),
                                          ),
                                        ],
                                      ));
                                },
                              )
                              // episodesList.isEmpty?:GridView.builder(
                              //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              //     crossAxisCount: 7, // 5 containers in a row
                              //     crossAxisSpacing: 8.0,
                              //     mainAxisSpacing: 8.0,
                              //   ),
                              //   itemCount: episodesList.length,
                              //   itemBuilder: (context, index) {
                              //     final episode = episodesList[index];
                              //     return GestureDetector(onTap: () async {
                              //       // Get.to(()=> AnimePlayerScreen(videoId: episode.episodeId));
                              //       Duration? pos = await videoPlayerService.videoController.position;
                              //       print('anime id ${animeDetails!.episodesList[selectedIndex.value].episodeId}, duration: ${pos!.inSeconds.toString()}');
                              //       animeWatcherController.storeData(animeDetails!.episodesList[selectedIndex.value].episodeId, pos.inSeconds.toString());
                              //       selectedIndex.value = index;
                              //       videoPlayerService.playingUrl.value = '';
                              //       print('anime id selected index $selectedIndex');
                              //       videoPlayerService.chewieController.pause();
                              //       videoPlayerService.chewieController.dispose();
                              //       videoPlayerService.videoController.dispose();
                              //       videoPlayerService.urls.clear();
                              //       videoPlayerService.playingUrl.value = episode.episodeUrl;
                              //       fetchVideoUrl(episode.episodeId);
                              //       // videoPlayerService.videoController.pause();
                              //     },
                              //         child: Stack(
                              //           children: [
                              //             Align(alignment: Alignment.center,child: Obx(() => Container(
                              //                 height: 50,width: 50,
                              //                 decoration: BoxDecoration(
                              //                     border: Border.all(color: Colors.black),
                              //                     borderRadius: BorderRadius.circular(10.0),
                              //                     color: selectedIndex.value == index? Colors.orangeAccent.shade200:(animeWatcherController.animeData.containsKey(episode.episodeId))?Colors.green.shade100.withOpacity(0.5):Colors.red.shade200.withOpacity(0.5)
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
                  bottomNavigationBar: animeDetails!.status == 'Upcoming'
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Upcoming',
                              style: myTextTheme.titleMedium,
                            )
                          ],
                        )
                      : const SizedBox(),
                );
              }
            })),
        onWillPop: () async {
          try {
            Duration? pos = await videoPlayerService.videoController.position;
            print(
                'in dispose id:${animeDetails!.episodesList[selectedEpIndex.value].episodeId}, pos: ${pos!.inSeconds.toString()}');
            animeWatcherController.storeData(
                animeDetails!.episodesList[selectedEpIndex.value].episodeId,
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
  //   print('in dispose id:${animeDetails!.episodesList[selectedIndex.value].episodeId}, pos: ${pos!.inSeconds.toString()}');
  //   animeWatcherController.storeData( animeDetails!.episodesList[selectedIndex.value].episodeId,pos.inSeconds.toString());
  //   await animeWatcherController.onClose();
  //   videoPlayerService.chewieController.dispose();
  //   videoPlayerService.dispose();
  // }
}

class ExpandableDescription extends StatefulWidget {
  final String description;

  ExpandableDescription({required this.description});

  @override
  _ExpandableDescriptionState createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 8),
            Padding(padding: EdgeInsets.symmetric(horizontal: 5), child: Text(
              widget.description,
              style: myTextTheme.bodySmall,
              maxLines: isExpanded ? 10000 : 5,
              overflow: TextOverflow.ellipsis,
            )),
            const SizedBox(height: 8),
            if (!isExpanded && widget.description.length > 5 * 30) // Assuming an average word length of 5 characters
              TextButton(
                onPressed: () {
                  setState(() {
                    isExpanded = true;
                  });
                },
                child: const Text('Show More'),
              ),
            if (isExpanded)
              TextButton(
                onPressed: () {
                  setState(() {
                    isExpanded = false;
                  });
                },
                child: const Text('Show Less'),
              ),
          ],
        );
      },
    );
  }
}


// class ExpandableDescription extends StatefulWidget {
//   final String description;
//
//   ExpandableDescription({required this.description});
//
//   @override
//   _ExpandableDescriptionState createState() => _ExpandableDescriptionState();
// }
//
// class _ExpandableDescriptionState extends State<ExpandableDescription> {
//   bool isExpanded = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final textPainter = TextPainter(
//           text: TextSpan(
//             text: widget.description,
//             style: myTextTheme.bodySmall,
//           ),
//           maxLines: 3,
//           textDirection: TextDirection.ltr,
//         )..layout(maxWidth: constraints.maxWidth);
//
//         final isTextOverflow = textPainter.didExceedMaxLines;
//
//         print('isTextOverflow $isTextOverflow');
//
//         return isTextOverflow
//             ? ExpansionTile(
//           title: Text('Anime Description',style: myTextTheme.bodyMedium,),
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 widget.description,
//                 style: myTextTheme.bodySmall,
//               ),
//             ),
//           ],
//         )
//             : Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text(
//             widget.description,
//             style: myTextTheme.bodySmall,
//           ),
//         );
//       },
//     );
//   }
// }
