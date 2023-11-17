import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:myanime/Controller/homeController.dart';
import 'package:myanime/Shared/theme.dart';

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
                    Text(
                      'Your watchlist',
                      style: myTextTheme.titleMedium,
                    ),
                    //Listview builder for watchlist
                    Expanded(
                        child: ListView.builder(
                            itemCount: homeController.watchList.length,
                            itemBuilder: (context, index) {
                              List<String> data =
                              homeController
                                  .watchList[index]
                                  .split(',');
                              return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Row(children: [
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
                                    const SizedBox(width: 10),

                                  ]));
                            })),
                  ]),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/watchlist.svg',
                    semanticsLabel: 'My SVG Image',
                    height: Get.width / 3,
                    width: Get.width / 3,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'There is no watchlist yet!',
                    style: myTextTheme.titleMedium,
                  ),
                  Text(
                    'Add to watchlist',
                    style: myTextTheme.titleMedium,
                  ),
                ],
              ),
            ),
    ));
  }
}
