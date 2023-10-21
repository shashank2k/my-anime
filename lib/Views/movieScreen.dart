import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myanime/Controller/movieController.dart';

import '../Controller/homeController.dart';
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
          return Center(child: CircularProgressIndicator());
        } else {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Set the number of columns
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
            ),
            itemCount: movieController.movies.length,
            itemBuilder: (context, index) {
              final movie = movieController.movies[index];
              return GestureDetector(onTap: (){
                Get.to(() => AnimeDetailsScreen(animeKey: movieController.movies[index].animeId));
              },child: Container(
                width: 120,
                height: 100,
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
              ),);
            },
          );
        }
      },
    );
  }
}
