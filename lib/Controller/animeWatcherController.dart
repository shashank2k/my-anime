import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnimeWatcherController extends GetxController {
  late Map<String, String> animeData;
  late SharedPreferences prefs;
  String animeTitle = '';
  List<String> recentWatches = [];

  String getTitle(){
    return animeTitle;
  }
  void setTitle(String title){
    animeTitle = title;
  }

  Future<void> init() async {
    // Initialize the map by retrieving data from SharedPreferences
    prefs = await SharedPreferences.getInstance();
    if(animeTitle != '')animeData = retrieveData();
  }


  // Future<void> storeData(String animeEp, Duration durationWatched) async {
  //   // Update the map with the new data
  //   if(durationWatched.inSeconds.toString() == '0') return;
  //   animeData[animeEp] = durationWatched.inSeconds.toString();
  //   print('Stored data for $animeTitle ,duration ${animeData[animeEp].toString()}');
  // }
  Future<void> storeData(String animeEp, String durationWatched) async {
    // Update the map with the new data
    if(durationWatched == '0') return;
    animeData[animeEp] = durationWatched;
    print('Stored data for $animeTitle ,duration ${animeData[animeEp]}');
  }

  void retrieveRecentWatches() {
    // Update the map with the new data
    print('in recent watches');
    recentWatches = prefs.getStringList('RecentWatchesList') ?? [];
    print('recent watches $recentWatches');
  }

  Map<String, String> retrieveData() {
    try{
      print('in retrieve data $animeTitle');
      final encodedData = prefs.getString(animeTitle);
      retrieveRecentWatches();
      print('recent watches $recentWatches');
      if (encodedData != null) {
        final decodedData = jsonDecode(encodedData);
        final Map<String, String> map = Map<String, String>.from(decodedData);
        print('in retrieve data ${map.toString()}');
        return map;
        // Convert the dynamic values to Duration
        // return Map<String, String>.fromEntries(
        //   map.entries.map((entry) {
        //     final animeEp = entry.key;
        //     print('in retirve seeked found ${entry.value}');
        //     return MapEntry(animeEp, entry.value);
        //   }),
        // );
    }else{
        print('in retrieve data nothing found');
      }
      }catch(e){
      print(e);
    }

    // Return an empty map if no data is found
    return {};
  }

  // int getLatestEp(){
  //   print('animeData.keys.last ${animeData.keys.last}');
  //   return extractEpisodeNumber(animeData.keys.last);
  // }
  String getLatestEp(){
    print('animeData.keys.last ${animeData.keys.last}');
    return animeData.keys.last;
  }

  @override
  Future<void> onClose() async {
    print('stored data closed');
    var episodes = animeData.keys.map((key) {
      var splits = key.split("-");
      return int.parse(splits.last.split("episode-").last);
    }).toList();

// Sort list
    episodes.sort();

// Map sorted keys back to Map
    var sortedMap = { for (var e in episodes) animeData.keys.firstWhere((k) => k.contains("episode-$e")) : animeData[animeData.keys.firstWhere((k) => k.contains("episode-$e"))] };

    final encodedData = jsonEncode(sortedMap);
    await prefs.setString(animeTitle, encodedData);
    super.onClose();
    print('Stored data: $animeData');

    prefs.setStringList('RecentWatchesList', recentWatches);

  }

}

int extractEpisodeNumber(String key) {
  try{
    print('for key $key returned ${key[key.length-1]} ');
    return int.parse(key[key.length-1]);
  }catch(e){
    print(e);
  }
  return 0; // Return 0 if no number is found
}
