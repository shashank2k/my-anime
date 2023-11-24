import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:myanime/Controller/movieController.dart';
import 'package:myanime/Shared/common.dart';
import 'package:myanime/Shared/theme.dart';
import 'movieDetailScreen.dart';

class MovieScreen extends StatefulWidget {
  const MovieScreen({super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  MovieController movieController = Get.put(MovieController());
  String searchText = '';
  RxBool loading = false.obs;
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    // if(movieController.movies.isEmpty) movieController.fetchMovies().then((value) => movieController.movies.value = value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // if (movieController.movies.isEmpty) {
    //   movieController.fetchMovies().then((value) {
    //     movieController.movies.value = value;
    //   });
    // }

    return Obx(() {
      if (movieController.movies.isEmpty && loading.value == true) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else if (movieController.movies.isEmpty && searchText.isEmpty) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //searchbar
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: SizedBox(
                      height: 60,
                      child: TextField(
                        controller: searchController,
                        style: myTextTheme.bodyLarge,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                          labelText: 'Search',
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.search_rounded,
                              size: 30,
                            ),
                            onPressed: () {
                              // searchText = '';
                              // searchController.clear();
                              movieController
                                  .fetchMovies(searchText)
                                  .then((value) {
                                movieController.movies.value = value;
                              });
                            },
                          ),
                        ),
                        onChanged: (value) {
                          searchText = value;
                          // setState(() {
                          //   searchText = value;
                          // });
                        },
                        onEditingComplete: () {
                          loading.value = true;
                          print('search text $searchText');
                          movieController.fetchMovies(searchText).then((value) {
                            movieController.movies.value = value;
                            loading.value = false;
                          });
                        },
                      ),
                    )),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        );
      } else {
        print('width ${Get.width}');
        searchController.text = searchText;
        return Scaffold(
          body: Column(
            children: [
              //searchbar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: SizedBox(
                    height: 50,
                    child: TextField(
                        controller: searchController,
                        style: myTextTheme.bodyMedium,
                        decoration: InputDecoration(
                          label: Text(
                            'Search',
                            style: myTextTheme.bodyMedium,
                          ),
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          suffixIcon: searchText.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.cancel_rounded),
                                  onPressed: () {
                                    searchText = '';
                                    searchController.clear();
                                  },
                                ),
                          // labelText: 'Search',
                          // hintText: searchText,
                        ),
                        onChanged: (value) {
                          searchText = value;
                          if (searchText.isEmpty || searchText.length == 1) {
                            setState(() {});
                          }
                          // setState(() {
                          //   searchText = value;
                          // });
                        },
                        onEditingComplete: () {
                          print('search text $searchText');
                          loading.value = true;
                          movieController.fetchMovies(searchText).then((value) {
                            movieController.movies.value = value;
                            loading.value = false;
                          });
                          print('performing get back');
                          Get.back();
                          print('performed get back');
                        })),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Text('Servers :',style: myTextTheme.bodyLarge,),
                  Obx(() => DropdownButton<int>(
                        value: movieController.selectedServer
                            .value, // Initially set to the first server
                        onChanged: (int? newIndex) {
                          // Handle dropdown value change
                          print(
                              'Selected Server: ${Common.movieUrls[newIndex!]}');
                          movieController.selectedServer.value = newIndex;
                        },
                        items: Common.movieUrls
                            .asMap()
                            .entries
                            .map<DropdownMenuItem<int>>((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text('Server ${entry.key + 1}',
                                style: myTextTheme.bodyMedium),
                          );
                        }).toList(),
                      )),
                  const SizedBox(
                    width: 20,
                  )
                  // DropdownButton<String>(
                  //   value: Common.movieUrls.isNotEmpty ? Common.movieUrls[0] : null,
                  //   onChanged: (String? newValue) {
                  //     // Handle dropdown value change
                  //     movieController.selectedServer = Common.movieUrls.indexOf(newValue!);
                  //     print('Selected Server: $newValue');
                  //   },
                  //   items: Common.movieUrls.map<DropdownMenuItem<String>>((String value) {
                  //     return DropdownMenuItem<String>(
                  //       value: value,
                  //       child: Text('Server $value',style: myTextTheme.bodyMedium,),
                  //     );
                  //   }).toList(),
                  // ),
                ],
              ),

              movieController.movies.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Column(
                          children: [
                            Lottie.asset(
                              'assets/lottie/emptySearch.json', // Replace with the path to your local JSON file
                              width: 200,
                              height: 200,
                              repeat: true, // Set to true if you want the animation to loop
                              reverse: false, // Set to true if you want the animation to play in reverse
                              animate: true, // Set to false if you want to start with the animation paused
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              'hmm...\nNo titles found.',
                              style: myTextTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: Stack(
                      children: [
                        loading.value
                            ? const Align(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(),
                              )
                            : const SizedBox(),
                        GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: Get.width > 800
                                ? 3
                                : 2, // Set the number of columns
                            crossAxisSpacing: 5.0,
                            mainAxisSpacing: 5.0,
                            childAspectRatio: 4 / 5,
                          ),
                          itemCount: movieController.movies.length,
                          itemBuilder: (context, index) {
                            final movie = movieController.movies[index];
                            if (index > movieController.movies.length - 5) {
                              movieController.fetchNextPage().then((value) {
                                movieController.movies.addAll(value);
                              });
                            }
                            return GestureDetector(
                              onTap: () {
                                print(
                                    'anime titile ${movieController.movies[index].animeTitle}');
                                Get.to(() =>
                                    // AnimeDetailsScreen(
                                    //   animeKey: movieController.movies[index].animeId,
                                    //   animeTitle: movieController.movies[index]
                                    //       .animeTitle,
                                    // ));
                                    MovieDetailsScreen(
                                      animeKey:
                                          movieController.movies[index].animeId,
                                      title: movieController
                                          .movies[index].animeTitle,
                                    ));
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                      child: Container(
                                    width: 135,
                                    height: 154,
                                    margin: const EdgeInsets.all(10),
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: movie.animeImg,
                                      placeholder: (context, url) =>
                                          const Center(
                                        widthFactor: 2,
                                        heightFactor: 2,
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (context, url, error) {
                                        print("Error loading image: $error");
                                        return const Icon(Icons.error);
                                      },
                                    ),
                                  )),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18),
                                    child: Text(
                                      movie.animeTitle,
                                      style: myTextTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      ],
                    ))
            ],
          ),
        );
      }
    });
  }
}
