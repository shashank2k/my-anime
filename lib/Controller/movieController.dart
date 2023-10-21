import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../Model/anime.dart';

class MovieController{

  RxList movies = [].obs;


  Future<List<Anime>> fetchMovies() async {
    try {
      final response = await Dio().get('https://my-anime.onrender.com/anime-movies');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return  data.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch recent releases');
      }
    } catch (e) {
      throw Exception('Failed to fetch recent releases: $e');
    }
  }
}