import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/anime.dart';

class HomeController{

  RxList recentRelease = [].obs;
  RxList popularAnime = [].obs;
  RxList topAiringAnime = [].obs;
  RxList watchList = [].obs;
  List<String> genre = [
    'action',
    'adventure',
    'cars',
    'comedy',
    'crime',
    'dementia',
    'demons',
    'drama',
    'dub',
    'ecchi',
    'family',
    'fantasy',
    'game',
    'gourmet',
    'harem',
    'historical',
    'horror',
    'josei',
    'kids',
    'magic',
    'martial-arts',
    'mecha',
    'military',
    'Mmusic',
    'mystery',
    'parody',
    'police',
    'psychological',
    'romance',
    'samurai',
    'school',
    'sci-fi',
    'seinen',
    'shoujo',
    'shoujo-ai',
    'shounen',
    'shounen-ai',
    'slice-of-Life',
    'space',
    'sports',
    'super-power',
    'supernatural,'
    'suspense',
    'thriller',
    'vampire',
    'yaoi',
    'yuri'
  ];

  Future<void> fetchWatchlist() async {
    if(watchList.isNotEmpty){
      return;
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      watchList.value = prefs.getStringList('watchList') ?? [];
    } catch (e) {
      throw Exception('Failed to fetch recent releases: $e');
    }
  }

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
      print('in popular anime');
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