import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:myanime/Controller/homeController.dart';
import 'package:myanime/Shared/theme.dart';

import 'animeDetailsScreen.dart';
import 'movieDetailScreen.dart';

class WatchListScreen extends StatefulWidget {
  const WatchListScreen({super.key});

  @override
  State<WatchListScreen> createState() => _WatchListScreenState();
}

class _WatchListScreenState extends State<WatchListScreen> {
  late HomeController homeController;

  @override
  void initState() {
    homeController = Get.put(HomeController());
    homeController.fetchWatchlist();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: homeController.watchList.isNotEmpty
          ? SizedBox(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Your watchlist',
                          style: myTextTheme.titleLarge,
                        ),
                        TextButton(onPressed: (){
                          homeController.watchList.clear();
                          homeController.storeWatchlist();
                          setState(() {

                          });
                        }, child: Text('Clear all',style: myTextTheme.titleMedium,))
                      ],
                    ),
                    //Listview builder for watchlist
                    Expanded(
                        child: ListView.builder(
                            itemCount: homeController.watchList.length,
                            itemBuilder: (context, index) {
                              List<String> data = [];
                              data.add(homeController.watchList[index].split(',').first);
                              if(homeController.watchList[index].split(',').last == 'movie') {
                                print('is movie ${homeController.watchList[index]}');
                                data.add(homeController.watchList[index].substring(homeController.watchList[index].indexOf(',')+1,homeController.watchList[index].indexOf('http')-1));
                                data.add(homeController.watchList[index].substring(homeController.watchList[index].indexOf('http'),homeController.watchList[index].lastIndexOf(',')));
                              }
                              else{
                                data.add(homeController.watchList[index].substring(homeController.watchList[index].indexOf(',')+1,homeController.watchList[index].lastIndexOf(',')));
                                data.add(homeController.watchList[index].split(',').last);
                              }
                              // List<String> data =
                              // homeController.watchList[index]
                              //     .split(',');
                              return GestureDetector(
                                onTap: (){
                                  print('last is ${homeController.watchList}');
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
                                child: Padding(
                                    padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: SizedBox(
                                          height: Get.width / 5,
                                          width: Get.width / 5,
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl: data[2],
                                            placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                            errorWidget: (context, url, error) {
                                              print(
                                                  "Error loading image: $error");
                                              return const Icon(Icons.error);
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 15,),
                                      Flexible(
                                        child: Text(
                                          data[1],
                                          style: myTextTheme.titleSmall,
                                          softWrap: true,
                                        ),
                                      ),

                                      // Column(
                                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      //   children: [
                                      //     Text(
                                      //       data[1],
                                      //       style: myTextTheme.titleMedium,
                                      //     ),
                                      //     // SizedBox(height: 8,),
                                      //     // Text(
                                      //     //   data[0],
                                      //     //   style: myTextTheme.titleSmall,
                                      //     // ),
                                      //   ],
                                      // ),
                                      const SizedBox(width: 20),

                                      IconButton(onPressed: (){
                                        homeController.watchList.removeAt(index);
                                        homeController.storeWatchlist();
                                        setState(() {

                                        });
                                      }, icon: const Icon(Icons.delete)),

                                    ])),
                              );
                            })),
                  ]),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/lottie/watchlist.json', // Replace with the path to your local JSON file
                    width: 200,
                    height: 200,
                    repeat: true, // Set to true if you want the animation to loop
                    reverse: false, // Set to true if you want the animation to play in reverse
                    animate: true, // Set to false if you want to start with the animation paused
                  ),
                  // SvgPicture.asset(
                  //   'assets/watchlist.svg',
                  //   semanticsLabel: 'My SVG Image',
                  //   height: Get.width / 3,
                  //   width: Get.width / 3,
                  // ),
                  const SizedBox(height: 10),
                  // Text(
                  //   'There is no watchlist yet!',
                  //   style: myTextTheme.titleMedium,
                  // ),
                  Text(
                    'Watchlist Empty!',
                    style: myTextTheme.titleMedium,
                  ),
                ],
              ),
            ),
    ));
  }
}
