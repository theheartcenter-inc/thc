import 'package:flutter/material.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/create_livestream/create_livestream.dart';
import 'package:thc/views/video_library/video_library.dart';
import 'package:thc/views/watch_live/watch_live.dart';

class ParticipantHomeScreen extends StatelessWidget {
  const ParticipantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const tabBar = TabBar(tabs: [Tab(text: 'watch live'), Tab(text: 'video library')]);
    const tabBarView = TabBarView(children: [WatchLive(), VideoLibrary()]);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: SafeArea(
            bottom: false,
            child: ColoredBox(
              color: context.theme.colorScheme.surface,
              child: tabBar,
            ),
          ),
        ),
        body: tabBarView,
      ),
    );
  }
}

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
      ),
      NavigationDestination(
        icon: Icon(Icons.stream),
        label: 'stream',
      ),
      NavigationDestination(
        selectedIcon: Icon(Icons.movie),
        icon: Icon(Icons.movie_outlined),
        label: 'library',
      ),
    ];
    const pages = [WatchLive(), CreateLivestream(), VideoLibrary()];

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
