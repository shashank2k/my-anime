
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:myanime/Controller/animeWatcherController.dart';
import 'package:myanime/Controller/homeController.dart';
import 'package:myanime/Views/animeDetailsScreen.dart';

import '../Model/anime.dart';
import '../Shared/theme.dart';
import 'movieDetailScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeController homeController = Get.put(HomeController());
  AnimeWatcherController animeWatcherController =
      Get.put(AnimeWatcherController());
  bool isDarkMode = false;
  String title = '';

  @override
  void initState() {
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    isDarkMode = brightness == Brightness.dark;
    print('is dark mode $isDarkMode');

    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    await animeWatcherController.init();
    animeWatcherController.retrieveRecentWatches();

    super.didChangeDependencies();
  }

  bool imagesPrecached = false;

  // Future<void> didChangeDependencies() async {
  //   await animeWatcherController.init();
  //   animeWatcherController.retrieveRecentWatches();
  //
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     for (var image in homeController.recentRelease) {
  //       String url = image.animeImg;
  //       precacheImage(NetworkImage(url), context);
  //     }
  //     for (var imageUrl in homeController.topAiringAnime) {
  //       String url = imageUrl.animeImg;
  //       precacheImage(NetworkImage(url), context);
  //       print('done for image $url');
  //       // precacheImage(NetworkImage(imageUrl), context);
  //     }
  //   });
  //
  //   // homeController.fetchTopAiringAnime().then((value) => (value) {
  //   //   homeController.topAiringAnime.value = value;
  //   // });
  //   // homeController.fetchRecentReleases().then((value) => (value) {
  //   //   homeController.recentRelease.value = value;
  //   // });
  //   // homeController.fetchPopularAnime().then((value) => (value) {
  //   //   homeController.popularAnime.value = value;
  //   // });
  //
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () => _refreshData(),
        child: Scaffold(
            body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SizedBox(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Releases',
                              style: myTextTheme.titleLarge,
                            ),
                            IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                // Open a search dialog or perform search actions here.
                                showSearch(context: context, delegate: AnimeSearchDelegate());
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Obx(
                              () => homeController.recentRelease.isNotEmpty
                              ? CarouselSlider(
                            items:
                            homeController.recentRelease.map((anime) {
                              return Builder(
                                builder: (BuildContext context) {
                                  title = (anime.animeTitle.toString().length > 35)?'${anime.animeTitle.toString().substring(0, 35)}...':anime.animeTitle.toString();
                                  return GestureDetector(
                                    onTap: () {
                                      Get.to(() => AnimeDetailsScreen(
                                          animeKey: anime.animeId,
                                          animeTitle: anime.animeTitle));
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: double
                                              .infinity, // Takes entire screen width
                                          height: Get.height /
                                              2, // 1/3 of screen height
                                          clipBehavior: Clip.hardEdge,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(
                                                5), // No rounded corners
                                          ),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.fill, // Cover the entire container
                                            width: double.infinity,
                                            imageUrl: anime.animeImg,
                                            placeholder: (context, url) =>
                                               Center(child: Lottie.asset(
                                                 'assets/lottie/imageLoading.json', // Replace with the path to your local JSON file
                                                 width: 80,
                                                 height: 80,
                                                 repeat: true, // Set to true if you want the animation to loop
                                                 reverse: false, // Set to true if you want the animation to play in reverse
                                                 animate: true, // Set to false if you want to start with the animation paused
                                               ),),
                                            errorWidget:
                                                (context, url, error) {
                                              print(
                                                  "Error loading image: $error");
                                              return const Icon(
                                                  Icons.error);
                                            },
                                          ),
                                        ),
                                        Positioned(
                                          bottom:
                                          10, // Adjust the distance from the bottom
                                          right:
                                          10, // Adjust the distance from the right
                                          child: Container(
                                            padding:
                                            const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: isDarkMode
                                                  ? Colors.black
                                                  .withOpacity(0.7)
                                                  : Colors.white.withOpacity(
                                                  0.9), // Adjust the background color and opacity
                                              borderRadius:
                                              BorderRadius.circular(
                                                  5),
                                            ),
                                            child: Text(
                                              title, // Your title here
                                              style:
                                              myTextTheme.bodyMedium,
                                              maxLines: 1,
                                              overflow: TextOverflow.fade,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                            options: CarouselOptions(
                              height:
                              Get.height / 2, // 1/3 of screen height
                              // Get.height / 2.3, // 1/3 of screen height
                              enlargeCenterPage: true,
                              // enlargeFactor: 2,
                              pageSnapping: true,
                              // viewportFraction: 0.75, // Show only one image at a time
                              viewportFraction: 1, // Show only one image at a time
                              enableInfiniteScroll: true, // Infinite loop
                              autoPlay: true, // Auto-play the carousel
                              autoPlayInterval: const Duration(
                                  seconds: 3), // Auto-play interval
                            ),
                          )
                              : SizedBox(width: Get.width,
                                height: Get.height/1.5,
                                child: Center(child: Column(children: [
                                  Lottie.asset(
                                    'assets/lottie/mainAppLoading.json', // Replace with the path to your local JSON file
                                    width: Get.width, // Adjust the width as needed
                                    height: Get.height/2,
                                    repeat: true, // Set to true if you want the animation to loop
                                    reverse: false, // Set to true if you want the animation to play in reverse
                                    animate: true, // Set to false if you want to start with the animation paused
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Opening Server...',
                                    style: myTextTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  )
                                ],
                                ),),
                              ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Obx(
                              () => homeController.topAiringAnime.isNotEmpty
                              ? TopAiringWidget()
                              : const SizedBox(),
                        ),

                        const SizedBox(
                          height: 10,
                        ),
                        animeWatcherController.recentWatches.isNotEmpty
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Continue watching',
                              style: myTextTheme.titleLarge,
                            ),
                            SizedBox(
                              height: 180,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: animeWatcherController
                                    .recentWatches.length,
                                clipBehavior: Clip.none,
                                itemBuilder: (context, index) {
                                  List<String> data = [];
                                  data.add(animeWatcherController
                                      .recentWatches[index].split(',').first);
                                  if(animeWatcherController.recentWatches[index].split(',').last == 'movie') {
                                    print('is movie ${animeWatcherController.recentWatches[index]}');
                                    data.add(animeWatcherController
                                        .recentWatches[index].substring(animeWatcherController
                                        .recentWatches[index].indexOf(',')+1,animeWatcherController
                                        .recentWatches[index].indexOf('http')-1));
                                    data.add(animeWatcherController
                                        .recentWatches[index].substring(animeWatcherController
                                        .recentWatches[index].indexOf('http'),animeWatcherController
                                        .recentWatches[index].lastIndexOf(',')));
                                  }
                                  else{
                                    data.add(animeWatcherController
                                        .recentWatches[index].substring(animeWatcherController
                                        .recentWatches[index].indexOf(',')+1,animeWatcherController
                                        .recentWatches[index].lastIndexOf(',')));
                                    data.add(animeWatcherController
                                        .recentWatches[index].split(',').last);
                                  }
                                  // List<String> data =
                                  // animeWatcherController
                                  //     .recentWatches[index]
                                  //     .split(',');
                                  print('data for $index is $data');
                                  print('image for $index is ${data[2]}');
                                  return GestureDetector(
                                    onTap: () {
                                      print('last is ${animeWatcherController
                                          .recentWatches[index]}');
                                      if(data.last == 'movie') {
                                        Get.to(() => MovieDetailsScreen(
                                          animeKey: data[0],
                                          title: data[1],
                                        ));
                                        return;
                                      }
                                      Get.to(() => AnimeDetailsScreen(
                                        animeKey: data[0],
                                        animeTitle: data[1],
                                      ));
                                    },
                                    child: Container(
                                      width:
                                      180, // Set the desired width for each item
                                      margin: const EdgeInsets.all(10),
                                      clipBehavior: Clip.hardEdge,
                                      decoration: const BoxDecoration(
                                        // borderRadius:  BorderRadius.circular(20)
                                          borderRadius:  BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)
                                          )),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 130,
                                            imageUrl: data[2],
                                            placeholder: (context, url) =>
                                                Center(child: Lottie.asset(
                                                  'assets/lottie/imageLoading.json', // Replace with the path to your local JSON file
                                                  width: 50,
                                                  height: 50,
                                                  repeat: true, // Set to true if you want the animation to loop
                                                  reverse: false, // Set to true if you want the animation to play in reverse
                                                  animate: true, // Set to false if you want to start with the animation paused
                                                ),),
                                            errorWidget:
                                                (context, url, error) {
                                              print(
                                                  "Error loading image: $error");
                                              return const Icon(
                                                  Icons.error);
                                            },
                                          ),
                                          const SizedBox(
                                              height:
                                              8), // Adjust the spacing between image and text
                                          Flexible(
                                            child: Text(
                                              data[1],
                                              maxLines:
                                              2, // You can adjust the number of lines
                                              overflow:
                                              TextOverflow.ellipsis,
                                              style:
                                              myTextTheme.bodySmall,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        )
                            : const SizedBox(),

                        // const SizedBox(height: 10,),

                        // Obx(
                        //       () => homeController.popularAnime.isNotEmpty
                        //       ? PopularWidget()
                        //       : const SizedBox(),
                        // ),

                        // GenreWidget(),

                        const SizedBox(height: 40,),
                      ],
                    ),
                  ),
                ))));
  }

  _refreshData() {
    homeController.recentRelease.clear();
    homeController.topAiringAnime.clear();
    homeController.fetchRecentReleases().then((data) {
      homeController.recentRelease.value = data;
    });
    homeController.fetchTopAiringAnime().then((data) {
      homeController.topAiringAnime.value = data;
    });
    return Future(() => true);

    // homeController.fetchPopularAnime().then((data) {
    //   print('popular');
    //   homeController.popularAnime.value = data;
    // });
  }
}

// class RecentWidget extends StatelessWidget {
//   final HomeController homeController = Get.put(HomeController());
//
//   RecentWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (homeController.recentRelease.isEmpty) {
//         return const Center(child: Text('No data'));
//       } else {
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Recent Releases'),
//             SizedBox(
//               height: 180,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: homeController.recentRelease.length,
//                 clipBehavior: Clip.none,
//                 itemBuilder: (context, index) {
//                   final anime = homeController.recentRelease[index];
//                   return GestureDetector(
//                     onTap: () {
//                       Get.to(() => AnimeDetailsScreen(animeKey: homeController.recentRelease[index].animeId, animeTitle: homeController.recentRelease[index].animeTitle,));
//                     },
//                     child: Container(
//                       width: 120, // Set the desired width for each item
//                       margin: const EdgeInsets.all(10),
//                       clipBehavior: Clip.hardEdge,
//                       decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                       color: isDarkMode?Colors.black:Colors.white.withOpacity(0.5)),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           CachedNetworkImage(
//                             fit: BoxFit.cover,
//                             width: double.infinity,
//                             height: 110,
//                             imageUrl: anime.animeImg,
//                             placeholder: (context, url) =>
//                                 const CircularProgressIndicator(),
//                             errorWidget: (context, url, error) {
//                               print("Error loading image: $error");
//                               return const Icon(Icons.error);
//                             },
//                           ),
//                           const SizedBox(
//                               height:
//                                   8), // Adjust the spacing between image and text
//                           Flexible(
//                             child: Text(
//                               anime.animeTitle,
//                               maxLines: 2, // You can adjust the number of lines
//                               overflow: TextOverflow.ellipsis,
//                               softWrap: true,
//                               style: myTextTheme.bodySmall,
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             )
//           ],
//         );
//       }
//     });
//   }
// }

class GenreWidget extends StatelessWidget {
  final HomeController homeController = Get.put(HomeController());

  GenreWidget({super.key});

  @override
  Widget build(BuildContext context) {
    RxInt selectedIndex = 0.obs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore Genres',
          style: myTextTheme.titleMedium,
        ),
        const SizedBox(height: 5,),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: homeController.genre.length,
            clipBehavior: Clip.none,
            itemBuilder: (context, index) {
              // final anime = homeController.popularAnime[index];
              return GestureDetector(
                onTap: () {
                  selectedIndex.value = index;
                  print('index is ${selectedIndex}');
                  // Get.to(() => AnimeDetailsScreen(
                  //   animeKey:
                  //   homeController.popularAnime[index].animeId, animeTitle: homeController.popularAnime[index].animeTitle,));
                },
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: 
                  Obx(() => Container(
                    // height: 50,
                    // width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: selectedIndex.value == index? Colors.red:Colors.grey,
                    ),
                    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 5),child: Center(child: Text(homeController.genre[index],style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: selectedIndex.value == index? Colors.white:Colors.black,
                    ),)),),
                  )),),

                // Stack(
                //   children: [
                //     Align(
                //       alignment: Alignment.center,
                //       child: Container(
                //         height: 50,
                //         width: 100,
                //         decoration: BoxDecoration(
                //           border: Border.all(color: Colors.black),
                //           borderRadius: BorderRadius.circular(10.0),
                //           color: Colors.grey,
                //         ),
                //       ),
                //     ),
                //     Align(
                //       alignment: Alignment.center,
                //       child: Text(
                //         homeController.genre[index],
                //         style: const TextStyle(
                //             fontSize: 16.0, overflow: TextOverflow.fade),
                //       ),
                //     ),
                //   ],
                // ),
              );
            },
          ),
        )
      ],
    );
  }
}

class PopularWidget extends StatelessWidget {
  final HomeController homeController = Get.put(HomeController());

  PopularWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (homeController.recentRelease.isEmpty) {
        return const Center(child: Text('No data'));
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Popular Anime',
              style: myTextTheme.titleMedium,
            ),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: homeController.popularAnime.length,
                clipBehavior: Clip.none,
                itemBuilder: (context, index) {
                  final anime = homeController.popularAnime[index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => AnimeDetailsScreen(
                            animeKey:
                                homeController.popularAnime[index].animeId,
                            animeTitle:
                                homeController.popularAnime[index].animeTitle,
                          ));
                    },
                    child: Container(
                      width: 140, // Set the desired width for each item
                      margin: const EdgeInsets.all(10),
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CachedNetworkImage(
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 180,
                            imageUrl: anime.animeImg,
                            placeholder: (context, url) =>
                                const Center(widthFactor: 2,heightFactor: 2,child: CircularProgressIndicator(),),
                            errorWidget: (context, url, error) {
                              print("Error loading image: $error");
                              return const Icon(Icons.error);
                            },
                          ),
                          const SizedBox(
                              height:
                                  8), // Adjust the spacing between image and text
                          Flexible(
                            child: Text(
                              anime.animeTitle,
                              maxLines: 2, // You can adjust the number of lines
                              overflow: TextOverflow.ellipsis,
                              style: myTextTheme.bodySmall,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        );
      }
    });
  }
}

class AnimeSearchDelegate extends SearchDelegate<String> {
  HomeController homeController = Get.put(HomeController());

  @override
  List<Widget> buildActions(BuildContext context) {
    // This is the "clear text" button in the search bar.
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // This is the "back" button in the search bar.
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Display the search results here.
    // You can build a list of search results or navigate to a search results screen.
    return FutureBuilder<List<Anime>>(
      future: homeController.fetchSearchedAnime(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Lottie.asset(
            'assets/lottie/mainAppLoading.json', // Replace with the path to your local JSON file
            width: 150, // Adjust the width as needed
            height: 150,
            repeat: true, // Set to true if you want the animation to loop
            reverse: false, // Set to true if you want the animation to play in reverse
            animate: true, // Set to false if you want to start with the animation paused
          ));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error.toString()}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No results found for "$query"'));
        } else {
          final searchResults = snapshot.data;
          return Padding(padding: const EdgeInsets.only(left: 5,right: 5,bottom: 10),child:GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Set the number of items per row
              childAspectRatio: 0.79,
              crossAxisSpacing: 10,
              mainAxisSpacing: 15,
            ),
            itemCount: searchResults!.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  print('tapped ${searchResults[index].animeId}');
                  close(context, '');
                  Get.to(() => AnimeDetailsScreen(
                    animeKey: searchResults[index].animeId,
                    animeTitle: searchResults[index].animeTitle,
                  ));
                },
                child: SizedBox(
                  // Set the desired width for each item
                  // margin: const EdgeInsets.symmetric(horizontal: 10),
                  // clipBehavior: Clip.hardEdge,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child:
                      Container(clipBehavior: Clip.hardEdge,decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),),
              ),child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 190,
                        imageUrl: searchResults[index].animeImg,
                        placeholder: (context, url) =>
                            Center(child: Lottie.asset(
                              'assets/lottie/imageLoading.json', // Replace with the path to your local JSON file
                              width: 50,
                              height: 50,
                              repeat: true, // Set to true if you want the animation to loop
                              reverse: false, // Set to true if you want the animation to play in reverse
                              animate: true, // Set to false if you want to start with the animation paused
                            ),),
                        errorWidget: (context, url, error) {
                          print("Error loading image: $error");
                          return const Icon(Icons.error);
                        },
                      ),)
                      ),
                      Text(
                        searchResults[index].animeTitle,
                        maxLines: 2, // You can adjust the number of lines
                        overflow: TextOverflow.ellipsis,
                        style: myTextTheme.bodySmall,
                      ),
                      // Flexible(
                      //   child:
                      // ),
                    ],
                  ),
                ),
              );
            },
          ));
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show suggestions as the user types.
    // You can fetch suggestions from your data source here.
    final suggestions = [
      'Naruto',
      'One Piece',
      'Attack on Titan',
      'My Hero Academia',
      'Demon Slayer',
    ];

    final suggestionList = query.isEmpty
        ? suggestions
        : suggestions.where((anime) {
      return anime.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return Scaffold(
        body: SizedBox(
          height: Get.height,
          width: Get.width,
          child: ListView.builder(
            itemCount: suggestionList.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  suggestionList[index],
                  style: myTextTheme.displaySmall,
                ),
                onTap: () {
                  // You can perform an action when a suggestion is selected.
                  query = suggestionList[index];
                  print('tapped ${suggestionList[index]}');
                  showResults(context);
                },
              );
            },
          ),
        ));
  }
}

class TopAiringWidget extends StatelessWidget {
  final HomeController homeController = Get.put(HomeController());

  TopAiringWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (homeController.topAiringAnime.isEmpty) {
        return const Center(child: Text('No data'));
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 5,
            ),
            Text(
              'Top Airing Anime',
              style: myTextTheme.titleLarge,
            ),
            SizedBox(
              height: 240,
              child:
              homeController.topAiringAnime.isEmpty ?
              // Center(
              //   child: Column(
              //     children: [
              //       Lottie.asset(
              //         'assets/lottie/emptySearch.json', // Replace with the path to your local JSON file
              //         width: 200,
              //         height: 200,
              //         repeat: true, // Set to true if you want the animation to loop
              //         reverse: false, // Set to true if you want the animation to play in reverse
              //         animate: true, // Set to false if you want to start with the animation paused
              //       ),
              //       const SizedBox(
              //         height: 20,
              //       ),
              //       Text(
              //         'hmm...\nNo titles found.',
              //         style: myTextTheme.bodyLarge,
              //         textAlign: TextAlign.center,
              //       )
              //     ],
              //   ),
              // )
                  const SizedBox():
              ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: homeController.topAiringAnime.length,
                clipBehavior: Clip.none,
                itemBuilder: (context, index) {
                  final anime = homeController.topAiringAnime[index];
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => AnimeDetailsScreen(
                            animeKey:
                                homeController.topAiringAnime[index].animeId,
                            animeTitle:
                                homeController.topAiringAnime[index].animeTitle,
                          ));
                    },
                    child: Container(
                      width: 140, // Set the desired width for each item
                      margin: const EdgeInsets.all(10),
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CachedNetworkImage(
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 180,
                            imageUrl: anime.animeImg,
                          placeholder: (context, url) =>
                              Center(child: Lottie.asset(
                                'assets/lottie/imageLoading.json', // Replace with the path to your local JSON file
                                width: 50,
                                height: 50,
                                repeat: true, // Set to true if you want the animation to loop
                                reverse: false, // Set to true if you want the animation to play in reverse
                                animate: true, // Set to false if you want to start with the animation paused
                              ),),
                            errorWidget: (context, url, error) {
                              print("Error loading image: $error");
                              return const Icon(Icons.error);
                            },
                          ),
                          const SizedBox(
                              height:
                                  2), // Adjust the spacing between image and text
                          Flexible(
                            child: Text(
                              anime.animeTitle,
                              style: myTextTheme.bodySmall,
                              maxLines: 2, // You can adjust the number of lines
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        );
      }
    });
  }
}
