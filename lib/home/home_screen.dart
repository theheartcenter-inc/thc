import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/home/library/video_library.dart';
import 'package:thc/home/profile/profile.dart';
import 'package:thc/home/schedule/schedule.dart';
import 'package:thc/home/stream/create_livestream.dart';
import 'package:thc/home/surveys/manage_surveys/manage_surveys.dart';
import 'package:thc/home/users/manage_users.dart';
import 'package:thc/home/watch_live/watch_live.dart';
import 'package:thc/utils/local_storage.dart';
import 'package:thc/utils/widgets/enum_widget.dart';

enum NavBarButton with StatelessEnum {
  /// A place for admins to manage other users.
  users(
    outlined: Icon(Icons.group_outlined),
    filled: Icon(Icons.group),
    screen: ManageUsers(),
  ),

  /// A place for admins to edit surveys, and view a summary of survey responses.
  surveys(
    outlined: Icon(Icons.leaderboard_outlined),
    filled: Icon(Icons.leaderboard),
    screen: ManageSurveys(),
  ),

  /// Participants can join an active livestream and view a schedule of upcoming streams.
  watchLive(
    outlined: Icon(Icons.spa_outlined),
    filled: Icon(Icons.spa),
    label: 'watch live',
    screen: WatchLive(),
  ),

  /// Users can view a schedule of upcoming livestreams.
  ///
  /// Admins can edit this schedule.
  schedule(
    outlined: Icon(Icons.calendar_month_outlined),
    filled: Icon(Icons.calendar_month),
    screen: Schedule(),
  ),

  /// A place for directors to start streaming.
  stream(
    outlined: Icon(Icons.stream),
    screen: CreateLivestream(),
  ),

  /// A catalog of recorded guided meditation videos.
  library(
    outlined: Icon(Icons.movie_outlined),
    filled: Icon(Icons.movie),
    screen: VideoLibrary(),
  ),

  /// View and manage account information.
  profile(
    outlined: Icon(Icons.account_circle_outlined),
    filled: Icon(Icons.account_circle),
    label: 'me',
    screen: ProfileScreen(),
  );

  const NavBarButton({
    required this.outlined,
    this.filled,
    this.label,
    required this.screen,
  });

  /// Shown when the button is unselected (and also when selected, if [filled] is null).
  final Icon outlined;

  /// A filled-in icon, used when the button is selected.
  final Icon? filled;

  /// If this is `null`, the enum value name will be used as the button label.
  final String? label;

  /// The screen to show when this button is selected.
  final Widget screen;

  /// Not every button should be enabled for every user,
  /// e.g. participants and directors don't have access to the admin portal.
  bool get enabled {
    final isAdmin = user.isAdmin;
    return switch (this) {
      watchLive when isAdmin => LocalStorage.adminWatchLive(),
      stream when isAdmin => LocalStorage.adminStream(),
      stream => user.canLivestream,
      users || surveys => isAdmin,
      watchLive || schedule || library || profile => true,
    };
  }

  /// The list of buttons to display at the bottom of the home screen.
  static List<NavBarButton> get enabledValues => List.of(values.where((value) => value.enabled));

  /// The button's position within [enabledValues].
  int get navIndex => max(enabledValues.indexOf(this), 0);

  /// These enum values can be built into a widget thanks to the [StatelessEnum] mixin.
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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navBar = NavBar.of(context);

    return Scaffold(
      body: SafeArea(bottom: false, child: navBar.screen),
      bottomNavigationBar: navBar,
    );
  }
}

/// {@template NavBar}
/// Why are we extending [NavigationBar] and making a BLoC class for state management?
///
/// Literally just so that the navigation bar slides down when you click "Go Live"
/// and then smoothly slides back up when the stream is over.
/// {@endtemplate}
class NavBar extends NavigationBar {
  /// {@macro NavBar}
  NavBar.of(BuildContext context, {super.key, this.belowPage = false})
      : super(
          selectedIndex: context.watch<NavBarIndex>().value,
          onDestinationSelected: (i) => context.read<NavBarIndex>().selectIndex(i),
          destinations: NavBarButton.enabledValues,
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

  Widget get screen => NavBarButton.enabledValues[selectedIndex].screen;

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

/// {@template NavBarIndex}
/// Updates the active [NavBar] index when you move to another page,
/// and when you turn a page on/off in the Admin settings.
/// {@endtemplate}
class NavBarIndex extends ValueNotifier<int> {
  /// {@macro NavBarIndex}
  NavBarIndex() : super(_initial);

  static int get _initial {
    final NavBarButton fromStorage = LocalStorage.navBarState();
    return fromStorage.navIndex;
  }

  /// This function is kinda tricky, since NavBar buttons have 2 indexes:
  /// 1. `index`: its index in [NavBarButton.values]
  /// 2. `navIndex`: its index in [NavigationBar.destinations]
  ///
  /// `index` is used in [LocalStorage], and `navIndex` is used in the [NavBar].
  void selectIndex(int navIndex) {
    final newButton = NavBarButton.enabledValues[navIndex];
    LocalStorage.navBarState.save(newButton.index);
    value = navIndex;
  }

  /// Similar to [selectIndex], but you can pass in the desired button directly.
  void selectButton(NavBarButton button) {
    return switch (NavBarButton.enabledValues.indexOf(button)) {
      < 0 =>
        throw UnsupportedError('"${user.type}" does not currently have access to "$button".'),
      final int navIndex => selectIndex(navIndex),
    };
  }

  /// Ensures that the index remains valid when an admin adds or removes a [NavBarButton].
  void refresh() => selectButton(NavBarButton.profile);
}
