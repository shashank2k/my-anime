import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:myanime/Controller/homeController.dart';
import 'package:myanime/Views/animeDetailsScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () => _refreshData(),
    child: Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(10),
      child:
      Column(
        children: [
          Obx(
                () => homeController.recentRelease.isNotEmpty
                ? SizedBox(height: 200,child: RecentWidget(),)
                : const SizedBox(),
          ),
          Obx(
                () => homeController.topAiringAnime.isNotEmpty
                ? SizedBox(height: 200,child: TopAiringWidget(),)
                : const SizedBox(),
          ),
          Obx(
                () => homeController.popularAnime.isNotEmpty
                ? SizedBox(height: 200,child: PopularWidget(),)
                : const SizedBox(),
          ),
        ],
      ),
    )));
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


class RecentWidget extends StatelessWidget {
  final HomeController homeController = Get.put(HomeController());

  RecentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (homeController.recentRelease.isEmpty) {
        return const Center(child: Text('No data'));
      } else {
        return
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text('Recent Releases'),
          SizedBox(height: 150,child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: homeController.recentRelease.length,
              clipBehavior: Clip.none,
              itemBuilder: (context, index) {
                final anime = homeController.recentRelease[index];
                return GestureDetector(onTap: (){

                  Get.to(() => AnimeDetailsScreen(animeKey: homeController.recentRelease[index].animeId));
                },child: Container(
                  width: 120, // Set the desired width for each image
                  height: 100,
                  margin: const EdgeInsets.all(10),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: anime.animeImg,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) {
                      print("Error loading image: $error");
                      return const Icon(Icons.error);
                    },
                  ),
                ));
              }),)

            ],
          );


      }
    });
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
        return
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text('Popular Anime'),
              SizedBox(height: 150,child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: homeController.popularAnime.length,
                  clipBehavior: Clip.none,
                  itemBuilder: (context, index) {
                    final anime = homeController.popularAnime[index];
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.all(10),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(flex: 7,// Adjust the height to fit the content
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: anime.animeImg,
                              placeholder: (context, url) => const CircularProgressIndicator(),
                              errorWidget: (context, url, error) {
                                print("Error loading image: $error");
                                return const Icon(Icons.error);
                              },
                            ),
                          ),
                          Flexible(flex: 1,child: Text(
                            homeController.popularAnime[index].animeTitle,
                            style: const TextStyle(overflow: TextOverflow.clip),
                          ),)

                        ],
                      ),
                    );
                  }
                  ),)

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
        return
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text('Top Airing Anime'),
              SizedBox(height: 150,child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: homeController.topAiringAnime.length,
                  clipBehavior: Clip.none,
                  itemBuilder: (context, index) {
                    final anime = homeController.topAiringAnime[index];
                    return Container(
                      width: 120, // Set the desired width for each image
                      height: 100,
                      margin: const EdgeInsets.all(10),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: anime.animeImg,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) {
                          print("Error loading image: $error");
                          return const Icon(Icons.error);
                        },
                      ),
                    );
                  }),)

            ],
          );


      }
    });
  }
}
