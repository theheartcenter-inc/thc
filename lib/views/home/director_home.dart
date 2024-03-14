import 'package:flutter/material.dart';
import 'package:thc/views/create_livestream/create_livestream.dart';
import 'package:thc/views/settings/settings.dart';
import 'package:thc/views/video_library/video_library.dart';
import 'package:thc/views/watch_live/watch_live.dart';

class DirectorHomeScreen extends StatefulWidget {
  const DirectorHomeScreen({super.key});

  @override
  State<DirectorHomeScreen> createState() => _DirectorHomeScreenState();
}

class _DirectorHomeScreenState extends State<DirectorHomeScreen> {
  int currentPageIndex = 0;
  @override
  Widget build(BuildContext context) {
    const navigateIcons = [
      NavigationDestination(
        selectedIcon: Icon(Icons.spa),
        icon: Icon(Icons.spa_outlined),
        label: 'watch live',
        tooltip: '',
      ),
      NavigationDestination(
        icon: Icon(Icons.stream),
        label: 'stream',
        tooltip: '',
      ),
      NavigationDestination(
        selectedIcon: Icon(Icons.movie),
        icon: Icon(Icons.movie_outlined),
        label: 'library',
        tooltip: '',
      ),
      NavigationDestination(
        selectedIcon: Icon(Icons.settings),
        icon: Icon(Icons.settings_outlined),
        label: 'settings',
        tooltip: '',
      ),
    ];
    const pages = [WatchLive(), CreateLivestream(), VideoLibrary(), SettingsScreen()];

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) => setState(() => currentPageIndex = index),
        selectedIndex: currentPageIndex,
        destinations: navigateIcons,
      ),
      body: pages[currentPageIndex],
    );
  }
}
