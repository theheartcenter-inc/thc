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
    final navigationBar = DirectorNavBar.of(context);
    return Scaffold(
      bottomNavigationBar: navigationBar,
      body: switch (navigationBar.selectedIndex) {
        0 => const WatchLive(),
        1 => const CreateLivestream(),
        2 => const VideoLibrary(),
        _ => const SettingsScreen(),
      },
    );
  }
}

/// {@template views.home.DirectorNavigationBar}
/// Why are we extending [NavigationBar] and making a BLoC class for state management?
///
/// Literally just so that the navigation bar slides down when you click "Go Live"
/// and then smoothly slides back up when the stream is over.
/// {@endtemplate}
class DirectorNavBar extends NavigationBar {
  /// {@macro views.home.DirectorNavigationBar}
  DirectorNavBar.of(BuildContext context, {super.key, this.belowPage = false})
      : super(
          selectedIndex: context.watch<DirectorNavigation>().state,
          onDestinationSelected: context.read<DirectorNavigation>().update,
          destinations: _destinations,
        );

  /// If [belowPage] is true, then instead of passing this widget
  /// into the [Scaffold.bottomNavigationBar] slot, [Scaffold.body] should be
  /// wrapped with a bottom-aligned [Stack] to hold this widget.
  ///
  /// If you're using VS Code or a similar IDE,
  /// click the code action lightbulb (💡) and choose "Wrap with Row".
  ///
  /// Then you can change the name "Row" to "Stack"
  /// and set its alignment to the bottom of the screen.
  final bool belowPage;

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
    final directorBar = Hero(
      tag: 'Director home screen bottom bar',
      child: super.build(context),
    );

    if (!belowPage) return directorBar;

    return Transform(
      transform: Matrix4.translationValues(0, 80, 0.0),
      child: directorBar,
    );
  }
}

/// {@macro views.home.DirectorNavigationBar}
class DirectorNavigation extends Cubit<int> {
  /// {@macro views.home.DirectorNavigationBar}
  DirectorNavigation() : super(_initial);

  static int get _initial => switch (StorageKeys.directorScreen()) {
        final int i when i >= 0 && i < DirectorNavBar._destinations.length => i,
        _ => 0,
      };

  void update(int index) {
    StorageKeys.directorScreen.save(index);
    emit(index);
  }
}
