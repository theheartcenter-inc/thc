import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/models/bloc.dart';
import 'package:thc/models/local_storage.dart';
import 'package:thc/views/create_livestream/create_livestream.dart';
import 'package:thc/views/settings/settings.dart';
import 'package:thc/views/video_library/video_library.dart';
import 'package:thc/views/watch_live/watch_live.dart';

class DirectorHomeScreen extends StatelessWidget {
  const DirectorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: context.watch<DirectorBar>().navigationBar,
      body: switch (DirectorBar.page) {
        0 => const WatchLive(),
        1 => const CreateLivestream(),
        2 => const VideoLibrary(),
        _ => const SettingsScreen(),
      },
    );
  }
}

class DirectorIcons extends NavigationBar {
  DirectorIcons({
    super.key,
    required super.selectedIndex,
    required super.onDestinationSelected,
  }) : super(destinations: _destinations);

  static const _destinations = <Widget>[
    NavigationDestination(
      icon: Icon(Icons.spa_outlined),
      selectedIcon: Icon(Icons.spa),
      label: 'watch live',
      tooltip: '',
    ),
    NavigationDestination(
      icon: Icon(Icons.stream),
      label: 'stream',
      tooltip: '',
    ),
    NavigationDestination(
      icon: Icon(Icons.movie_outlined),
      selectedIcon: Icon(Icons.movie),
      label: 'library',
      tooltip: '',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'settings',
      tooltip: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Hero(tag: 'Director icons', child: super.build(context));
  }
}

class DirectorBar extends CustomBloc<DirectorIcons> {
  static final _controller = StreamController<DirectorIcons>.broadcast();
  @override
  StreamController<DirectorIcons> get controller => _controller;

  static int page = switch (StorageKeys.directorScreen()) {
    final int i when i > 0 && i <= DirectorIcons._destinations.length => i,
    _ => 0,
  };

  DirectorIcons get navigationBar => DirectorIcons(
        selectedIndex: page,
        onDestinationSelected: (index) {
          page = index;
          StorageKeys.directorScreen.save(index);
          controller.add(navigationBar); // ignore: recursive_getters
        },
      );
  Widget get belowPage {
    return Container(
      alignment: Alignment.bottomCenter,
      transform: Matrix4.translationValues(0, 80, 0.0),
      child: navigationBar,
    );
  }
}
