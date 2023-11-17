import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myanime/Controller/movieController.dart';
import 'package:myanime/Shared/theme.dart';

import 'animeDetailsScreen.dart';
class MovieScreen extends StatefulWidget {
  const MovieScreen({super.key});

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  MovieController movieController = Get.put(MovieController());
  @override
  void initState() {
    if(movieController.movies.isEmpty) movieController.fetchMovies().then((value) => movieController.movies.value = value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (movieController.movies.isEmpty) {
      movieController.fetchMovies().then((value) {
        movieController.movies.value = value;
      });
    }

    return Obx(
          () {
        if (movieController.movies.isEmpty) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()),);
        } else {
          print('width ${Get.width}');
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: Get.width > 800?3:2, // Set the number of columns
              crossAxisSpacing: 5.0,
              mainAxisSpacing: 5.0,
              childAspectRatio: 4/5,
            ),
            itemCount: movieController.movies.length,
            itemBuilder: (context, index) {
              final movie = movieController.movies[index];
              return GestureDetector(onTap: (){
                print('anime titile ${movieController.movies[index].animeTitle}');
                Get.to(() => AnimeDetailsScreen(animeKey: movieController.movies[index].animeId, animeTitle: movieController.movies[index].animeTitle,));
              },
                child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child:  Container(
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
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) {
                          print("Error loading image: $error");
                          return const Icon(Icons.error);
                        },
                      ),
                    )),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 18),child: Text(movie.animeTitle,style: myTextTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis,),),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
