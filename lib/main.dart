import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myanime/Controller/homeController.dart';
import 'package:myanime/Shared/theme.dart';
import 'package:myanime/Views/homeScreen.dart';
import 'package:myanime/Views/movieScreen.dart';
import 'package:myanime/Views/watchlistScreen.dart';

import 'Controller/animeWatcherController.dart';
import 'Service/notificationService.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();

  runApp(ThemeProvider(
    settings: ValueNotifier(ThemeSettings(
      sourceColor: Colors.pink,
      themeMode: ThemeMode.system,
    )),
    lightDynamic:
        const ColorScheme.light(), // Replace with your light color scheme
    darkDynamic:
        const ColorScheme.dark(), // Replace with your dark color scheme
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    return GetMaterialApp(
        theme: themeProvider.theme(context),
        initialBinding: BindingsBuilder(() {
          Get.lazyPut(() => AnimeWatcherController());
        }),
        home: const MyHomePage(title: 'My anime app'));
    // return MaterialApp(
    //   title: 'My Anime',
    //   theme: ThemeData(
    //     colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    //     useMaterial3: true,
    //     textTheme: myTextTheme,
    //   ),
    //   home: const MyHomePage(title: 'My anime app'),
    // );
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

  RxInt _selectedIndex = 0.obs;
  // RxBool isDarkMode = false.obs;
  // static const TextStyle optionStyle =
  //     TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    MovieScreen(),
    WatchListScreen(),
  ];

  // void _onItemTapped(int index) {
  //
  //   // setState(() {
  //   //   _selectedIndex = index;
  //   // });
  // }
  void _onSwipeLeft() {
    print('swiped left');
    if (_selectedIndex < _widgetOptions.length - 1) {
      _selectedIndex.value++;
      // setState(() {
      //   _selectedIndex++;
      // });
    }
  }

  void _onSwipeRight() {
    print('swiped right');
    if (_selectedIndex > 0) {
      _selectedIndex.value--;
      // setState(() {
      //   _selectedIndex--;
      // });
    }
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

    // homeController.fetchPopularAnime().then((data) {
    //   print('popular');
    //   homeController.popularAnime.value = data;
    // });

    homeController.fetchTopAiringAnime().then((data) {
      print('top');
      homeController.topAiringAnime.value = data;
    });

    // var brightness =
    //     SchedulerBinding.instance.platformDispatcher.platformBrightness;
    // isDarkMode.value = brightness == Brightness.dark;
    // print('darkmode $isDarkMode');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('My Anime',style: GoogleFonts.poppins(fontSize: 22,fontWeight: FontWeight.bold)),
      //   actions: <Widget>[
      //     IconButton(
      //       icon: const Icon(Icons.search),
      //       onPressed: () {
      //         // Open a search dialog or perform search actions here.
      //         showSearch(context: context, delegate: AnimeSearchDelegate());
      //       },
      //     ),
      //   ],
      // ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 10,vertical: 15),
          child:
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 25,),
              // Row(
              //   children: [
              //     Text('My Anime',style: GoogleFonts.poppins(fontSize: 22,fontWeight: FontWeight.bold)),
              //     const Spacer(),
              //     IconButton(
              //       icon: const Icon(Icons.search),
              //       onPressed: () {
              //         // Open a search dialog or perform search actions here.
              //         showSearch(context: context, delegate: AnimeSearchDelegate());
              //       },
              //     ),
              //   ],
              // ),

              // AppBar(
              //   title: Text('My Anime',style: GoogleFonts.poppins(fontSize: 22,fontWeight: FontWeight.bold)),
              //   actions: <Widget>[
              //     IconButton(
              //       icon: const Icon(Icons.search),
              //       onPressed: () {
              //         // Open a search dialog or perform search actions here.
              //         showSearch(context: context, delegate: AnimeSearchDelegate());
              //       },
              //     ),
              //   ],
              // ),
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      _selectedIndex.value = 0;
                      // _onItemTapped(0);
                    },
                    child: TweenAnimationBuilder<Color?>(
                      tween: ColorTween(
                        begin: _selectedIndex.value == 0 ? Colors.transparent : Colors.black,
                        end: _selectedIndex.value == 0 ? Colors.red : Colors.transparent,
                        // end: _selectedIndex == 0 ? Colors.red :isDarkMode.value ? Colors.white : Colors.black,
                      ),
                      duration: const Duration(milliseconds: 300),
                      builder: (_, color, child) {
                        return Text(
                          'Anime',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color != Colors.transparent? color : null,
                          ),
                        );
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _selectedIndex.value = 1;
                      // _onItemTapped(1);
                    },
                    child: TweenAnimationBuilder<Color?>(
                      tween: ColorTween(
                        begin: _selectedIndex.value == 1 ? Colors.transparent : Colors.black,
                        // end: _selectedIndex == 1 ? Colors.red :isDarkMode.value ? Colors.white : Colors.black,
                        end: _selectedIndex.value == 1 ? Colors.red : Colors.transparent,
                      ),
                      duration: const Duration(milliseconds: 300),
                      builder: (_, color, child) {
                        return Text(
                          'Movies',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color != Colors.transparent? color : null,
                          ),
                        );
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _selectedIndex.value = 2;
                      // _onItemTapped(2);
                    },
                    child: TweenAnimationBuilder<Color?>(
                      tween: ColorTween(
                        begin: _selectedIndex.value == 2 ? Colors.transparent : Colors.black,
                        end: _selectedIndex.value == 2 ? Colors.red  : Colors.transparent,
                        // end: _selectedIndex == 2 ? Colors.red  : isDarkMode.value ? Colors.white : Colors.black,
                      ),
                      duration: const Duration(milliseconds: 300),
                      builder: (_, color, child) {
                        return Text(
                          'My List',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color != Colors.transparent? color : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ))
            ],
          ),

          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     GestureDetector(
          //       onTap: () {
          //         _onItemTapped(0);
          //       },
          //       child: Text(
          //         'Home',
          //         style: GoogleFonts.poppins(
          //             fontSize: 16,
          //             fontWeight: FontWeight.bold,
          //             color: _selectedIndex == 0
          //                 ? Colors.red
          //                 : isDarkMode
          //                     ? Colors.white
          //                     : Colors.black),
          //       ),
          //     ),
          //     GestureDetector(
          //         onTap: () {
          //           _onItemTapped(1);
          //         },
          //         child: Text(
          //           'Movies',
          //           style: GoogleFonts.poppins(
          //               fontSize: 16,
          //               fontWeight: FontWeight.bold,
          //               color: _selectedIndex == 1
          //                   ? Colors.red
          //                   : isDarkMode
          //                       ? Colors.white
          //                       : Colors.black),
          //         )),
          //     GestureDetector(
          //         onTap: () {
          //           _onItemTapped(2);
          //         },
          //         child: Text('My List',
          //             style: GoogleFonts.poppins(
          //                 fontSize: 16,
          //                 fontWeight: FontWeight.bold,
          //                 color: _selectedIndex == 2
          //                     ? Colors.red
          //                     : isDarkMode
          //                         ? Colors.white
          //                         : Colors.black))),
          //   ],
          // ),
        ),),
      body:
      WillPopScope(child: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity != null) {
            // Check if the swipe is in the left or right direction
            if (details.primaryVelocity! < 0) {
              // Swiped to the left
              _onSwipeLeft();
            } else if (details.primaryVelocity! > 0) {
              // Swiped to the right
              _onSwipeRight();
            }
          }
        },
        child: Obx(() => Center(
          child: _widgetOptions.elementAt(_selectedIndex.value),
        )),
      ), onWillPop:  () async {
        showModalBottomSheet(context: context, builder: (context) {
          return Container(
              width: Get.width,
              height: 110,
              decoration: BoxDecoration(
                  // color: isDarkMode?Colors.black:Colors.white,
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20))),
              // padding: const EdgeInsets.symmetric(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Do you want to exit the app?',style: myTextTheme.bodyMedium,),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children: [
                    ElevatedButton(onPressed: () {
                      Navigator.pop(context);
                      exit(0);
                      // return true;
                    }, child: Text('Yes',style: myTextTheme.bodyMedium,)),
                    ElevatedButton(onPressed: () {
                      Navigator.pop(context);
                    }, child: Text('No',style: myTextTheme.bodyMedium,)),])
                ],)
          );
        });
        return false;
      })
      // bottomNavigationBar: ClipRRect(
      //   clipBehavior: Clip.hardEdge,
      //   borderRadius: const BorderRadius.only(
      //     topLeft: Radius.circular(16), // Adjust the border radius as needed
      //     topRight: Radius.circular(16), // Adjust the border radius as needed
      //   ),
      //   child: BottomNavigationBar(
      //     items: const <BottomNavigationBarItem>[
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.home),
      //         label: 'Home',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.movie_creation_rounded),
      //         label: 'Movies',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.bookmark),
      //         label: 'Watch list',
      //       ),
      //     ],
      //     currentIndex: _selectedIndex,
      //     selectedItemColor: Colors.pinkAccent.shade100,
      //     onTap: _onItemTapped,
      //     unselectedLabelStyle: myTextTheme.bodySmall,
      //     selectedLabelStyle: myTextTheme.titleSmall,
      //     elevation: 5,
      //   ),
      // )
      // ,
    );
  }
}
