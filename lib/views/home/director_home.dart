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

/// We could just use a plain [NavigationBar] for [DirectorBar] below,
/// but extending the class makes the BLoC implementation a lot cleaner.
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
    return Hero(tag: 'Director home screen bottom bar', child: super.build(context));
  }
}

/// Why are we making a BLoC class for the navigation bar?
///
/// Literally just so that it slides down when you click "Go Live"
/// and then smoothly slides back up when the stream is over.
///
/// (Technically this shouldn't even be called a `BLoC`, since it's for a UI component.)
class DirectorBar extends CustomBloc<DirectorIcons> {
  static final _controller = StreamController<DirectorIcons>.broadcast();
  @override
  StreamController<DirectorIcons> get controller => _controller;

  static int page = switch (StorageKeys.directorScreen()) {
    final int i when i > 0 && i <= DirectorIcons._destinations.length => i,
    _ => 0,
  };

  /// Slap this bad boy right into a [Scaffold]—
  ///
  /// ```dart
  /// Scaffold(
  ///   bottomNavigationBar: context.watch<DirectorBar>().navigationBar,
  /// )
  /// ```
  DirectorIcons get navigationBar => DirectorIcons(
        selectedIndex: page,
        onDestinationSelected: (index) {
          page = index;
          StorageKeys.directorScreen.save(index);
          controller.add(navigationBar); // ignore: recursive_getters
        },
      );

  /// This guy should probably be at the bottom of a [Stack].
  Widget get belowPage => Container(
        alignment: Alignment.bottomCenter,
        transform: Matrix4.translationValues(0, 80, 0.0),
        child: navigationBar,
      );
}
