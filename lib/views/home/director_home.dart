import 'package:flutter/material.dart';
import 'package:thc/models/local_storage.dart';
import 'package:thc/views/create_livestream/create_livestream.dart';
import 'package:thc/views/settings/settings.dart';
import 'package:thc/views/video_library/video_library.dart';
import 'package:thc/views/watch_live/watch_live.dart';

enum DirectorScreen {
  watchLive(
    screen: WatchLive(),
    icon: Icons.spa,
    outlined: Icons.spa_outlined,
  ),
  stream(
    screen: CreateLivestream(),
    icon: Icons.stream,
  ),
  library(
    screen: VideoLibrary(),
    icon: Icons.movie,
    outlined: Icons.movie_outlined,
  ),
  settings(
    screen: SettingsScreen(),
    icon: Icons.settings,
    outlined: Icons.settings_outlined,
  );

  const DirectorScreen({required this.screen, required this.icon, this.outlined});
  final Widget screen;
  final IconData icon;
  final IconData? outlined;

  static DirectorScreen? get initial {
    final fromStorage = StorageKeys.directorScreen();
    if (fromStorage == null) return /* userType.isAdmin ? null : */ watchLive;

    assert(fromStorage is int);
    assert(fromStorage >= 0 && fromStorage < values.length);
    return values[fromStorage];
  }

  void save() => StorageKeys.directorScreen.save(index);

  // static NavigationDestination get _adminPortalButton => throw UnimplementedError();
  NavigationDestination get _button => NavigationDestination(
        icon: Icon(outlined ?? icon),
        selectedIcon: Icon(icon),
        label: this == watchLive ? 'watch live' : name,
        tooltip: '',
      );

  static List<NavigationDestination> get _buttons => [
        // if (userType.isAdmin) _adminPortalButton,
        for (final value in values) value._button,
      ];
}

class DirectorHomeScreen extends StatefulWidget {
  const DirectorHomeScreen({super.key});

  @override
  State<DirectorHomeScreen> createState() => _DirectorHomeScreenState();
}

class _DirectorHomeScreenState extends State<DirectorHomeScreen> {
  DirectorScreen page = DirectorScreen.initial!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: DirectorScreen._buttons,
        selectedIndex: page.index,
        onDestinationSelected: (index) {
          setState(() => page = DirectorScreen.values[index]);
          page.save();
        },
      ),
      body: page.screen,
    );
  }
}
