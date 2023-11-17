import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myanime/Controller/animeWatcherController.dart';
import 'package:myanime/Controller/homeController.dart';
import 'package:myanime/Views/animeDetailsScreen.dart';

import '../Shared/theme.dart';

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

    // homeController.fetchTopAiringAnime().then((value) => (value) {
    //   homeController.topAiringAnime.value = value;
    // });
    // homeController.fetchRecentReleases().then((value) => (value) {
    //   homeController.recentRelease.value = value;
    // });
    // homeController.fetchPopularAnime().then((value) => (value) {
    //   homeController.popularAnime.value = value;
    // });

    super.didChangeDependencies();
  }

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
                        Text(
                          'Recent Releases',
                          style: myTextTheme.displaySmall,
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
                                            children: [
                                              Container(
                                                width: double
                                                    .infinity, // Takes entire screen width
                                                height: Get.height /
                                                    3, // 1/3 of screen height
                                                clipBehavior: Clip.hardEdge,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5), // No rounded corners
                                                ),
                                                child: CachedNetworkImage(
                                                  fit: BoxFit
                                                      .cover, // Cover the entire container
                                                  width: double.infinity,
                                                  imageUrl: anime.animeImg,
                                                  placeholder: (context, url) =>
                                                      const CircularProgressIndicator(),
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
                                                            0.5), // Adjust the background color and opacity
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Text(
                                                    title, // Your title here
                                                    style:
                                                        myTextTheme.bodySmall,
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
                                        Get.height / 3, // 1/3 of screen height
                                    viewportFraction:
                                        1.0, // Show only one image at a time
                                    enableInfiniteScroll: true, // Infinite loop
                                    autoPlay: true, // Auto-play the carousel
                                    autoPlayInterval: const Duration(
                                        seconds: 3), // Auto-play interval
                                  ),
                                )
                              : const SizedBox(),
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
                                    style: myTextTheme.displaySmall,
                                  ),
                                  SizedBox(
                                    height: 180,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: animeWatcherController
                                          .recentWatches.length,
                                      clipBehavior: Clip.none,
                                      itemBuilder: (context, index) {
                                        List<String> data =
                                            animeWatcherController
                                                .recentWatches[index]
                                                .split(',');
                                        print('image for $index is ${data[2]}');
                                        return GestureDetector(
                                          onTap: () {
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
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20)),
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
                                                      const CircularProgressIndicator(),
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
                            :
                        // const CircularProgressIndicator(),
                        const SizedBox(),

                        // const SizedBox(height: 10,),

                        Obx(
                          () => homeController.popularAnime.isNotEmpty
                              ? PopularWidget()
                              : const SizedBox(),
                        ),

                        GenreWidget(),

                        const SizedBox(height: 40,),
                      ],
                    ),
                  ),
                ))));
  }

  _refreshData() {
    homeController.fetchRecentReleases().then((data) {
      homeController.recentRelease.value = data;
    });

    homeController.fetchPopularAnime().then((data) {
      print('popular');
      homeController.popularAnime.value = data;
    });
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
          style: myTextTheme.displaySmall,
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
              style: myTextTheme.displaySmall,
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
                                const CircularProgressIndicator(),
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
              style: myTextTheme.displaySmall,
            ),
            SizedBox(
              height: 240,
              child: ListView.builder(
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
                                const CircularProgressIndicator(),
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
