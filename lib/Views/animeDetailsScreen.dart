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

class AnimeDetailsScreen extends StatefulWidget {
  final String animeKey;
  final String animeTitle;


  const AnimeDetailsScreen({super.key, required this.animeKey, required this.animeTitle});

  @override
  State<AnimeDetailsScreen> createState() => _AnimeDetailsScreenState();
}

class _AnimeDetailsScreenState extends State<AnimeDetailsScreen> {
  AnimeDetails? animeDetails;
  late AnimeWatcherController animeWatcherController;
  RxString playingUrl = ''.obs;
  RxInt selectedIndex = 0.obs;
  List<String> urls = [];
  final VideoPlayerService videoPlayerService = Get.put(VideoPlayerService());
  HomeController homeController = Get.put(HomeController());
  var animeData;
  RxBool hasData = false.obs;
  Icon bookmarkIcon = const Icon(Icons.bookmark_border);

  @override
  void initState()  {
    super.initState();
    animeWatcherController = Get.put(AnimeWatcherController());
    animeWatcherController.setTitle(widget.animeTitle);
    // animeWatcherController.retrieveData();
  }

  @override
  Future<void> didChangeDependencies() async {
    animeDetails = await fetchAnimeDetails(widget.animeKey);
    await animeWatcherController.init();
    super.didChangeDependencies();
  }

  Future<AnimeDetails> fetchAnimeDetails(String key) async {
    final response = await Dio().get('https://my-anime.onrender.com/anime-details/$key');

    print('https://my-anime.onrender.com/anime-details/$key');
    print('anime details');

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
    final response =
    await Dio().get('https://my-anime.onrender.com/vidcdn/watch/$videoId');
    print('https://my-anime.onrender.com/vidcdn/watch/$videoId');
    print('anime key ${widget.animeTitle} id: $videoId');
    print('in retrive ${animeWatcherController.animeData.containsKey(videoId)} ${animeWatcherController.animeData[videoId]}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = response.data;
      final List<dynamic> sources = responseData['sources'];
      print('anime key ${widget.animeTitle}');
      if (sources.isNotEmpty) {
        final String videoUrl =
        sources[0]['file']; // Assuming the first source is the video URL
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
        if(animeWatcherController.animeData.containsKey(videoId)){
          print('seeked to ${Duration(seconds: int.parse(animeWatcherController.animeData[videoId]!))}');
          await videoPlayerService.videoController.seekTo(Duration(seconds: int.parse(animeWatcherController.animeData[videoId]!)));
        }
        playingUrl.value = videoUrl;
        for (var items in sources) {
          print('have link');
          urls.add(items['file']);
        }
        // animeWatcherController.storeData( videoId, Duration.zero);
        // videoPlayerService.videoController.play();
        videoPlayerService.chewieController.play();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.animeTitle,style: myTextTheme.displayMedium,),
        actions: [
          IconButton(
            onPressed: () {
              hasData.value = true;
              if(homeController.watchList.contains('${widget.animeKey},${widget.animeTitle},${animeData.animeImg}')) {
                homeController.watchList.removeWhere((element) => element.contains('${widget.animeKey},${widget.animeTitle},${animeData.animeImg}'));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Removed from watchlist',style: myTextTheme.titleMedium),));
                return;
              }
              homeController.watchList.add('${widget.animeKey},${widget.animeTitle},${animeData.animeImg}');
              print('added ${widget.animeKey},${widget.animeTitle},${animeData.animeImg}');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added to watchlist',style: myTextTheme.titleMedium,),));
            },
            // icon: Obx(() => hasData.value ?(homeController.watchList.contains('${widget.animeKey},${widget.animeTitle},${animeData.animeImg}') ? const Icon(Icons.bookmark) : const Icon(Icons.bookmark_outline)):const Icon(Icons.bookmark_outline),
            icon: Obx(() => hasData.value ?(homeController.watchList.contains('${widget.animeKey},${widget.animeTitle},${animeData.animeImg}') ? const Icon(Icons.bookmark) : const Icon(Icons.bookmark_outline)):const Icon(Icons.bookmark_outline),
            ),)
        ],
      ),
      body:
          Obx(() {
            if(!hasData.value){
              return const Center(child: CircularProgressIndicator(),);
            }
            else{
              animeData = animeDetails!;
              if(!animeWatcherController.recentWatches.contains('${widget.animeKey},${widget.animeTitle},${animeData.animeImg}'))animeWatcherController.recentWatches.add('${widget.animeKey},${widget.animeTitle},${animeData.animeImg}');
              try{
                String key = animeWatcherController.getLatestEp();
                print('key $key');
                selectedIndex.value = animeData.episodesList.indexWhere((element) => element.episodeId == key);
                // playingUrl.value = animeData.episodesList[selectedIndex.value].episodeUrl;
              }
              catch(e){
                print('in catch');
                if(selectedIndex.value == 0) selectedIndex.value = animeData.episodesList.length - 1;
              }
              print('selected ${selectedIndex.value}');
              // print('fetching ${animeData.episodesList.length}');
              if(animeData.totalEpisodes != '0') fetchVideoUrl(animeData.episodesList.last.episodeId);
              // Use animeData to display details on the screen
              return Scaffold(body:
              SizedBox(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.center,children: [
                Obx(
                      () {
                    if (playingUrl.value != '') {
                      // return SizedBox(width: Get.width,height: Get.height / 4,child: VideoPlayer(videoPlayerService.videoController),);
                      return FittedBox(fit: BoxFit.cover,child: SizedBox(width: Get.width,height: Get.height / 3,child: Chewie(
                        controller: videoPlayerService.chewieController,
                      ),),);
                      // return SizedBox(width: Get.width,height: Get.height / 4,child: VideoPlayer(videoPlayerService.videoController),);
                    } else {
                      return SizedBox(
                        height: Get.height / 3,
                        width: double.infinity,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: animeData.animeImg,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) {
                            print("Error loading image: $error");
                            return const Icon(Icons.error);
                          },
                        ),
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
                Text('Anime Title: ${animeData.animeTitle}'),
                Text('Type: ${animeData.type}'),
                const SizedBox(height: 200,),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 5),child:  SizedBox(height: Get.height/3,child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, // 5 containers in a row
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: animeData.episodesList.length,
                  itemBuilder: (context, index) {
                    final episode = animeData.episodesList[index];
                    return GestureDetector(onTap: () async {
                      // Get.to(()=> AnimePlayerScreen(videoId: episode.episodeId));
                      Duration? pos = await videoPlayerService.videoController.position;
                      print('anime id ${animeData.episodesList[selectedIndex.value].episodeId}, duration: ${pos!.inSeconds.toString()}');
                      animeWatcherController.storeData(animeData.episodesList[selectedIndex.value].episodeId, pos.inSeconds.toString());
                      selectedIndex.value = index;
                      playingUrl.value = '';
                      print('anime id ');
                      videoPlayerService.videoController.pause();
                      fetchVideoUrl(episode.episodeId);
                      // videoPlayerService.videoController.pause();
                    },
                        child: Stack(
                          children: [
                            Obx(() => Align(alignment: Alignment.center,child: Container(
                                height: 50,width: 50,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: selectedIndex.value == index? Colors.orangeAccent.shade200:(animeWatcherController.animeData.containsKey(episode.episodeId))?Colors.green.shade100.withOpacity(0.5):Colors.red.shade200.withOpacity(0.5)
                                )),),),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                episode.episodeNum,
                                style: const TextStyle(fontSize: 16.0,overflow: TextOverflow.fade),
                              ),
                            ),
                          ],));
                  },
                ),),)
              ],)),),
                bottomNavigationBar: animeData.status == 'Upcoming'?Row(mainAxisAlignment: MainAxisAlignment.center,children: [ Text('Upcoming',style: myTextTheme.titleMedium,)],):const SizedBox(),
              );
            }

          })

    );
  }
  @override
  Future<void> dispose() async {
    try{
      super.dispose();
    }catch(e){
      print('caught stored data closed super failed $e');
    }
    Duration? pos = await videoPlayerService.videoController.position;
    print('in dispose id:${animeData.episodesList[selectedIndex.value].episodeId}, pos: ${pos!.inSeconds.toString()}');
    animeWatcherController.storeData( animeData.episodesList[selectedIndex.value].episodeId,pos.inSeconds.toString());
    await animeWatcherController.onClose();
    videoPlayerService.chewieController.dispose();
    videoPlayerService.dispose();
  }
}