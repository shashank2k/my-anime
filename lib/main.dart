import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myanime/Controller/homeController.dart';
import 'package:myanime/Shared/theme.dart';
import 'package:myanime/Views/homeScreen.dart';
import 'package:myanime/Views/movieScreen.dart';
import 'package:myanime/Views/watchlistScreen.dart';

import 'Controller/animeWatcherController.dart';
import 'Model/anime.dart';
import 'Service/notificationService.dart';
import 'Views/animeDetailsScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();

  runApp(ThemeProvider(
    settings: ValueNotifier(ThemeSettings(
      sourceColor: Colors.pink,
      themeMode: ThemeMode.system,
    )),
    lightDynamic: const ColorScheme.light(), // Replace with your light color scheme
    darkDynamic: const ColorScheme.dark(),   // Replace with your dark color scheme
    child: const MyApp(),));
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
        textTheme: myTextTheme,
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
    WatchListScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {

    // serverCheckService.initializeNotifications();
    // serverCheckService.checkServerAndNotify('https://my-anime.onrender.com');
    // NotificationService().showNotification(id: 0,title: 'My- anime',body: 'hey');


    NotificationService().checkConnection();

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
    final themeProvider = ThemeProvider.of(context);
    return GetMaterialApp(theme: themeProvider.theme(context),initialBinding: BindingsBuilder(() {
      Get.lazyPut(() => AnimeWatcherController());
    }),home:  Scaffold(
      appBar: AppBar(
        title: Text('My Anime',style: GoogleFonts.poppins(fontSize: 22,fontWeight: FontWeight.bold)),
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
      bottomNavigationBar: ClipRRect(
        clipBehavior: Clip.hardEdge,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16), // Adjust the border radius as needed
          topRight: Radius.circular(16), // Adjust the border radius as needed
        ),
        child: BottomNavigationBar(
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
              icon: Icon(Icons.bookmark),
              label: 'Watch list',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.pinkAccent.shade100,
          onTap: _onItemTapped,
          unselectedLabelStyle: myTextTheme.bodySmall,
          selectedLabelStyle: myTextTheme.titleSmall,
          elevation: 5,
        ),
      )
      ,
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
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Set the number of items per row

            ),
            itemCount: searchResults!.length,

            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  print('tapped ${searchResults[index].animeId}');
                  close(context, '');
                  Get.to(() => AnimeDetailsScreen(animeKey: searchResults[index].animeId, animeTitle: searchResults[index].animeTitle,));
                },
                child: Container(
                  height: 200,
                  width: 160, // Set the desired width for each item
                  margin: const EdgeInsets.all(10),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CachedNetworkImage(
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 160,
                        imageUrl: searchResults[index].animeImg,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) {
                          print("Error loading image: $error");
                          return const Icon(Icons.error);
                        },
                      ),
                      const SizedBox(
                        height: 2, // Adjust the spacing between image and text
                      ),
                      Flexible(
                        child: Text(
                          searchResults[index].animeTitle,
                          maxLines: 2, // You can adjust the number of lines
                          overflow: TextOverflow.ellipsis,
                          style: myTextTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
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

    return Scaffold(
      body: SizedBox(height: Get.height,width: Get.width,child: ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(suggestionList[index],style: myTextTheme.displaySmall,),
            onTap: () {
              // You can perform an action when a suggestion is selected.
              query = suggestionList[index];
              showResults(context);
            },
          );
        },
      ),)
    );


  }

}

