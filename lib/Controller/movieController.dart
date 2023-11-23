import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:myanime/Shared/common.dart';

import '../Model/anime.dart';

class MovieController{

  RxList movies = [].obs;
  RxInt selectedServer = 0.obs;
  bool hasNext = false;
  int currentPage = 1;
  String query = "";


  Future<List<Anime>> fetchMovies(String query) async {
    try {
      final response = await Dio().get(Common.movieUrls[selectedServer.value]+query);
      if (response.statusCode == 200) {
        print(response.data);
        hasNext = response.data['hasNextPage'];
        this.query = query;
        currentPage = 1;
        final List<dynamic> data = response.data['results'];
        return  data.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch recent releases');
      }
    } catch (e) {
      throw Exception('Failed to fetch recent releases: $e');
    }
  }

  Future<List<Anime>> fetchMovieDetails(String query) async {
    try {
      final response = await Dio().get(Common.movieUrls[selectedServer.value]+query);
      if (response.statusCode == 200) {
        print(response.data);
        hasNext = response.data['hasNextPage'];
        this.query = query;
        currentPage = 1;
        final List<dynamic> data = response.data['results'];
        return  data.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch recent releases');
      }
    } catch (e) {
      throw Exception('Failed to fetch recent releases: $e');
    }
  }

  Future<List<Anime>> fetchNextPage() async {
    if(!hasNext || query == "") return [];
    try {
      final response = await Dio().get(Common.movieUrls[selectedServer.value]+query,queryParameters: {"page": currentPage+1});
      if (response.statusCode == 200) {
        print(response.data);
        hasNext = response.data['hasNextPage'];
        currentPage++;
        final List<dynamic> data = response.data['results'];
        return  data.map((json) => Anime.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch recent releases');
      }
    } catch (e) {
      throw Exception('Failed to fetch recent releases: $e');
    }
  }
}