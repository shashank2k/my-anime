import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../Model/anime.dart';

class HomeController{

  RxList recentRelease = [].obs;
  RxList popularAnime = [].obs;
  RxList topAiringAnime = [].obs;

  Future<List<Anime>> fetchRecentReleases() async {
    try {
      final response = await Dio().get('https://my-anime.onrender.com/recent-release');
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

  Future<List<Anime>> fetchPopularAnime() async {
    try {
      final response = await Dio().get('https://my-anime.onrender.com/popular');
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

  Future<List<Anime>> fetchTopAiringAnime() async {
    try {
      final response = await Dio().get('https://my-anime.onrender.com/top-airing');
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

  Future<List<Anime>> fetchSearchedAnime(String key) async {
    try {
      final response = await Dio().get('https://my-anime.onrender.com/search?keyw=$key');
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