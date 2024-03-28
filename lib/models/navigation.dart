import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/models/bloc.dart';
import 'package:thc/models/local_storage.dart';
import 'package:thc/models/user.dart';
import 'package:thc/views/create_livestream/create_livestream.dart';
import 'package:thc/views/settings/settings.dart';
import 'package:thc/views/user_management/user_management.dart';
import 'package:thc/views/video_library/video_library.dart';
import 'package:thc/views/watch_live/watch_live.dart';

/// {@template models.navigator}
/// We can make navigation a little cleaner with a global key and an extension type:
///
/// ```dart
/// // before
/// Navigator.of(context).push(
///   MaterialPageRoute(builder: (context) => const NewPage()),
/// );
///
/// // after
/// navigator.push(const NewPage());
/// ```
///
/// For times when you want to configure the page route,
/// you can still use `Navigator.of(context)`.
/// {@endtemplate}
final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

/// {@macro models.navigator}
Nav get navigator => Nav(navKey.currentState!);

/// {@template models.navigator_example}
/// Example:
///
/// ```dart
/// void main() {
///   runApp(const App()); // "/"
/// }
///
/// navigator.push(const Screen1()); // "/Screen1"
///
/// navigator.push(const Screen2()); // "/Screen1/Screen2"
///
/// navigator.pushReplacement(const Replacement()); // "/Screen1/Replacement"
///
/// navigator.pop(); // "/Screen1"
///
/// navigator.pop(); // "/"
/// ```
/// {@endtemplate}
extension type Nav(NavigatorState navigator) {
  /// Adds a new screen to the route.
  ///
  /// {@macro models.navigator_example}
  Future<T?> push<T>(Widget destination) =>
      navigator.push<T>(MaterialPageRoute<T>(builder: (context) => destination));

  /// Adds a new screen in place of the current screen.
  ///
  /// {@macro models.navigator_example}
  Future<void> pushReplacement(Widget destination) => navigator.pushReplacement<void, void>(
        MaterialPageRoute<void>(builder: (context) => destination),
      );

  /// Removes the current screen from the route.
  ///
  /// {@macro models.navigator_example}
  void pop<T>([T? value]) => navigator.maybePop<T>(value);
}

enum NavBarData {
  manageUsers(
    outlined: Icon(Icons.group_outlined),
    filled: Icon(Icons.group),
    label: 'users',
    page: UserManagement(),
  ),
  watchLive(
    outlined: Icon(Icons.spa_outlined),
    filled: Icon(Icons.spa),
    label: 'watch live',
    page: WatchLive(),
  ),
  stream(
    outlined: Icon(Icons.stream),
    page: CreateLivestream(),
  ),
  library(
    outlined: Icon(Icons.movie_outlined),
    filled: Icon(Icons.movie),
    page: VideoLibrary(),
  ),
  settings(
    outlined: Icon(Icons.settings_outlined),
    filled: Icon(Icons.settings),
    page: SettingsScreen(),
  );

  const NavBarData({required this.outlined, this.filled, this.label, required this.page});

  final Icon outlined;
  final Icon? filled;
  final String? label;
  final Widget page;

  bool get enabled {
    final bool isAdmin = userType.isAdmin;
    return switch (this) {
      watchLive when isAdmin => StorageKeys.adminWatchLive(),
      stream when isAdmin => StorageKeys.adminStream(),
      stream => userType.canLivestream,
      manageUsers => isAdmin,
      watchLive || library || settings => true,
    };
  }

  NavigationDestination get button => NavigationDestination(
      key: Key(name), icon: outlined, selectedIcon: filled, label: label ?? name, tooltip: '');
}

List<NavBarData> get enabledScreens => [
      for (final screen in NavBarData.values)
        if (screen.enabled) screen
    ];

List<NavigationDestination> get _destinations => [
      for (final screen in enabledScreens) screen.button,
    ];

class NavBar extends NavigationBar {
  NavBar.of(BuildContext context, {super.key, this.belowPage = false})
      : super(
          selectedIndex: context.watch<NavBarIndex>().state,
          onDestinationSelected: (newIndex) {
            context.read<NavBarIndex>().update(newIndex);
          },
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

  Widget get page => enabledScreens[selectedIndex].page;

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

/// {@template models.NavBarIndex}
/// Updates the active [NavBar] index when you move to another page,
/// and when you turn a page on/off in the Admin settings.
/// {@endtemplate}
class NavBarIndex extends Cubit<int> {
  /// {@macro models.NavBarIndex}
  NavBarIndex() : super(_initial);

  static int get _initial => max(enabledScreens.indexOf(StorageKeys.navBarState()), 0);

  /// This function is kinda tricky, since the new screen has 2 indexes:
  /// 1. its index in [NavBarData.values]
  /// 2. its index in [enabledScreens]
  ///
  /// #1 is used in [StorageKeys], and #2 is used in the [NavBar].
  void update(int index) {
    final newScreen = enabledScreens[index];
    StorageKeys.navBarState.save(newScreen.index);
    emit(index);
  }

  void refresh() => update(enabledScreens.indexOf(NavBarData.settings));
}
