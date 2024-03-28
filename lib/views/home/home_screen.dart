import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/models/bloc.dart';
import 'package:thc/models/enum_widget.dart';
import 'package:thc/models/local_storage.dart';
import 'package:thc/models/user.dart';
import 'package:thc/views/create_livestream/create_livestream.dart';
import 'package:thc/views/manage_surveys/manage_surveys.dart';
import 'package:thc/views/manage_users/manage_users.dart';
import 'package:thc/views/profile/profile.dart';
import 'package:thc/views/video_library/video_library.dart';
import 'package:thc/views/watch_live/watch_live.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navBar = NavBar.of(context);

    return Scaffold(
      body: navBar.page,
      bottomNavigationBar: navBar,
    );
  }
}

enum NavBarButton with StatelessEnum {
  users(
    outlined: Icon(Icons.group_outlined),
    filled: Icon(Icons.group),
    page: ManageUsers(),
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
  surveys(
    outlined: Icon(Icons.leaderboard_outlined),
    filled: Icon(Icons.leaderboard),
    page: ManageSurveys(),
  ),
  library(
    outlined: Icon(Icons.movie_outlined),
    filled: Icon(Icons.movie),
    page: VideoLibrary(),
  ),
  profile(
    outlined: Icon(Icons.account_circle_outlined),
    filled: Icon(Icons.account_circle),
    label: 'me',
    page: ProfilesScreen(),
  );

  const NavBarButton({
    required this.outlined,
    this.filled,
    this.label,
    required this.page,
  });

  final Icon outlined;
  final Icon? filled;
  final String? label;
  final Widget page;

  bool get buttonEnabled {
    final bool isAdmin = userType.isAdmin;
    return switch (this) {
      watchLive when isAdmin => StorageKeys.adminWatchLive(),
      stream when isAdmin => StorageKeys.adminStream(),
      stream => userType.canLivestream,
      users || surveys => isAdmin,
      watchLive || library || profile => true,
    };
  }

  static List<NavBarButton> get enabled => List.of(values.where((value) => value.buttonEnabled));
  int get navIndex => max(enabled.indexOf(this), 0);

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: outlined,
      selectedIcon: filled,
      label: label ?? name,
      tooltip: '',
    );
  }
}

class NavBar extends NavigationBar {
  NavBar.of(BuildContext context, {super.key, this.belowPage = false})
      : super(
          selectedIndex: context.watch<NavBarIndex>().state,
          onDestinationSelected: (i) => context.read<NavBarIndex>().update(i),
          destinations: NavBarButton.enabled,
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

  Widget get page => NavBarButton.enabled[selectedIndex].page;

  @override
  Widget build(BuildContext context) {
    final navBar = Hero(
      tag: 'Admin home screen bottom bar',
      child: super.build(context),
    );

    if (!belowPage) return navBar;

    return Transform(
      transform: Matrix4.translationValues(0, 80, 0.0),
      child: navBar,
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

  static int get _initial {
    final NavBarButton fromStorage = StorageKeys.navBarState();
    return fromStorage.navIndex;
  }

  /// This function is kinda tricky, since NavBar buttons have 2 indexes:
  /// 1. `index`: its index in [NavBarButton.values]
  /// 2. `navIndex`: its index in [NavigationBar.destinations]
  ///
  /// `index` is used in [StorageKeys], and `navIndex` is used in the [NavBar].
  void update(int navIndex) {
    final newButton = NavBarButton.enabled[navIndex];
    StorageKeys.navBarState.save(newButton.index);
    emit(navIndex);
  }

  void refresh() => update(NavBarButton.profile.navIndex);
}
