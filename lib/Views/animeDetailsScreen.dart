import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myanime/Views/animePlayerScreen.dart';

import '../Model/animedetails.dart';

class AnimeDetailsScreen extends StatefulWidget {
  final String animeKey;

  const AnimeDetailsScreen({required this.animeKey, Key? key}) : super(key: key);

  @override
  State<AnimeDetailsScreen> createState() => _AnimeDetailsScreenState();
}

class _AnimeDetailsScreenState extends State<AnimeDetailsScreen> {
  late Future<AnimeDetails> animeDetails;

  @override
  void initState() {
    super.initState();
    animeDetails = fetchAnimeDetails(widget.animeKey);
  }

  Future<AnimeDetails> fetchAnimeDetails(String key) async {
    final response = await Dio().get('https://my-anime.onrender.com/anime-details/$key');

    print('https://my-anime.onrender.com/anime-details/$key');

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = response.data;
      return AnimeDetails.fromJson(json);
    } else {
      throw Exception('Failed to load anime details');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anime Details'),
      ),
      body: FutureBuilder<AnimeDetails>(
        future: animeDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          } else {
            final animeData = snapshot.data!;
            // Use animeData to display details on the screen
            return Scaffold(body: SizedBox(child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.center,children: [
              SizedBox(height: Get.height/3,width: double.infinity,child: CachedNetworkImage(
                fit: BoxFit.cover,
                imageUrl: animeData.animeImg,
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) {
                  print("Error loading image: $error");
                  return const Icon(Icons.error);
                },
              ),),
              Text('Anime Title: ${animeData.animeTitle}'),
              Text('Type: ${animeData.type}'),
              SizedBox(height: 200,),
              SizedBox(height: Get.height/3,child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7, // 5 containers in a row
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: animeData.episodesList.length,
                itemBuilder: (context, index) {
                  final episode = animeData.episodesList[index];
                  return GestureDetector(onTap: (){
                    Get.to(()=> AnimePlayerScreen(videoId: episode.episodeId));
                  },
                      child: Stack(
                    children: [
                      Align(alignment: Alignment.center,child: Container(
                          height: 50,width: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(10.0),
                          )),),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          episode.episodeNum,
                          style: const TextStyle(fontSize: 16.0,overflow: TextOverflow.fade),
                        ),
                      ),
                    ],));
                },
              ),),
            ],)),),
              bottomNavigationBar: Padding(padding: const EdgeInsets.symmetric(horizontal: 15,),child: ElevatedButton(child: Text('View Anime'),onPressed: () {
                Get.to(()=> AnimePlayerScreen(videoId: animeData.episodesList.last.episodeId));
              },),),
            );
          }
        },
      ),
    );
  }
}



