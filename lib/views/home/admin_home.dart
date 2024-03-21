import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/models/bloc.dart';
import 'package:thc/models/local_storage.dart';
import 'package:thc/views/schedule_livestream/schedule_livestream.dart';
import 'package:thc/views/settings/settings.dart';
import 'package:thc/views/video_library/video_library.dart';
import 'package:thc/views/watch_live/watch_live.dart';
import 'package:thc/views/user_management/user_management.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationBar = AdminNavBar.of(context);
    return Scaffold(
      bottomNavigationBar: navigationBar,
      body: switch (navigationBar.selectedIndex) {
        0 => const WatchLive(),
        1 => const ScheduleLivestream(),
        2 => const VideoLibrary(),
        3 => const UserManagement(),
        _ => const SettingsScreen(),
      },
    );
  }
}

/// {@template views.home.AdminNavigationBar}
/// Why are we extending [NavigationBar] and making a BLoC class for state management?
///
/// Literally just so that the navigation bar slides down when you click "Go Live"
/// and then smoothly slides back up when the stream is over.
/// {@endtemplate}
class AdminNavBar extends NavigationBar {
  /// {@macro views.home.AdminNavigationBar}
  AdminNavBar.of(BuildContext context, {super.key, this.belowPage = false})
      : super(
    selectedIndex: context.watch<AdminNavigation>().state,
    onDestinationSelected: context.read<AdminNavigation>().update,
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
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month),
      label: 'schedule',
      tooltip: '',
    ),
    NavigationDestination(
      icon: Icon(Icons.movie_outlined),
      selectedIcon: Icon(Icons.movie),
      label: 'library',
      tooltip: '',
    ),
    NavigationDestination(
      icon: Icon(Icons.group_outlined),
      selectedIcon: Icon(Icons.group),
      label: 'user mgmt',
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
    final adminBar = Hero(
      tag: 'Admin home screen bottom bar',
      child: super.build(context),
    );

    if (!belowPage) return adminBar;

    return Transform(
      transform: Matrix4.translationValues(0, 80, 0.0),
      child: adminBar,
    );
  }
}

/// {@macro views.home.AdminNavigationBar}
class AdminNavigation extends Cubit<int> {
  /// {@macro views.home.AdminNavigationBar}
  AdminNavigation() : super(_initial);

  static int get _initial => switch (StorageKeys.adminScreen()) {
    final int i when i >= 0 && i < AdminNavBar._destinations.length => i,
    _ => 0,
  };

  void update(int index) {
    StorageKeys.adminScreen.save(index);
    emit(index);
  }
}
