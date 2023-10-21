import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:myanime/Controller/homeController.dart';
import 'package:myanime/Views/homeScreen.dart';
import 'package:myanime/Views/movieScreen.dart';

import 'Model/anime.dart';
import 'Views/animeDetailsScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Anime',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'My anime app'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  HomeController homeController = Get.put(HomeController());

  // List<> pages = [];

  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    MovieScreen(),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    homeController.fetchRecentReleases().then((data) {
      homeController.recentRelease.value = data;
    });

    homeController.fetchPopularAnime().then((data) {
      print('popular');
      homeController.popularAnime.value = data;
    });

    homeController.fetchTopAiringAnime().then((data) {
      print('top');
      homeController.topAiringAnime.value = data;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(home:  Scaffold(
      appBar: AppBar(
        title: const Text('My Anime'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Open a search dialog or perform search actions here.
              showSearch(context: context, delegate: AnimeSearchDelegate());
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_creation_rounded),
            label: 'Movies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'School',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    ),);
  }
}
class AnimeSearchDelegate extends SearchDelegate<String> {
  HomeController homeController = Get.put(HomeController());
  @override
  List<Widget> buildActions(BuildContext context) {
    // This is the "clear text" button in the search bar.
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // This is the "back" button in the search bar.
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Display the search results here.
    // You can build a list of search results or navigate to a search results screen.
    return FutureBuilder<List<Anime>>(
      future: homeController.fetchSearchedAnime(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error.toString()}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No results found for "$query"'));
        } else {
          final searchResults = snapshot.data;
          return ListView.builder(
            itemCount: searchResults!.length,
            itemBuilder: (context, index) {
              return ListTile(
                onTap: () {
                  print('tapped ${searchResults[index].animeId}');
                  close(context, '');
                  Get.to(() => AnimeDetailsScreen(animeKey: searchResults[index].animeId));
                },
                  title: Text(searchResults[index].animeTitle),
                  trailing: Container(
                    margin: const EdgeInsets.all(10),
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: searchResults[index].animeImg,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) {
                        print("Error loading image: $error");
                        return const Icon(Icons.error);
                      },
                    ),
                  )
                // You can customize how you want to display the search results.
              );
            },
          );
        }
      },
    );

  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show suggestions as the user types.
    // You can fetch suggestions from your data source here.
    final suggestions = [
      'Naruto',
      'One Piece',
      'Attack on Titan',
      'My Hero Academia',
      'Demon Slayer',
    ];

    final suggestionList = query.isEmpty
        ? suggestions
        : suggestions.where((anime) {
      return anime.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestionList[index]),
          onTap: () {
            // You can perform an action when a suggestion is selected.
            query = suggestionList[index];
            showResults(context);
          },
        );
      },
    );
  }
}

