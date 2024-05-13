import 'package:flutter/material.dart';
import 'package:thc/main.dart';
import 'package:thc/utils/local_storage.dart';
import 'package:thc/utils/widgets/lerpy_hero.dart';

/// {@template navigator}
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
GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

/// {@macro navigator}
Nav get navigator => Nav(navKey.currentState!);

/// {@template navigator_example}
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
extension type Nav(NavigatorState currentState) {
  /// Adds a new screen to the route.
  ///
  /// {@macro navigator_example}
  Future<T?> push<T>(Widget destination) =>
      currentState.push<T>(MaterialPageRoute<T>(builder: (context) => destination));

  /// Adds a new screen in place of the current screen.
  ///
  /// {@macro navigator_example}
  Future<T?> pushReplacement<T, TO>(Widget destination, {TO? result}) {
    return currentState.pushReplacement<T, TO>(
      MaterialPageRoute<T>(builder: (context) => destination),
      result: result,
    );
  }

  /// Removes the current screen from the route.
  ///
  /// {@macro navigator_example}
  void pop<T>([T? value]) => currentState.maybePop<T>(value);

  void noTransition(Widget destination, {bool replacing = false}) {
    final route = PageRouteBuilder(
      pageBuilder: (context, _, __) => destination,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );

    replacing ? currentState.pushReplacement(route) : currentState.push(route);
  }

  static const lerpy = Key("it's a LerpyHero!");

  /// Creates a pop-up dialog.
  ///
  /// The [dialog] should be an [AlertDialog] or something similar.
  Future<T?> showDialog<T>(
    Widget dialog, {
    bool barrierDismissible = true,
    Color? barrierColor,
    Duration? transitionDuration,
  }) {
    Widget builder(_) => dialog;

    return dialog.key == lerpy
        ? currentState.push<T>(
            LerpyHeroRoute(
              barrierColor: barrierColor,
              transitionDuration: transitionDuration,
              barrierDismissible: barrierDismissible,
              builder: builder,
            ),
          )
        : showAdaptiveDialog<T>(
            context: currentState.context,
            barrierColor: barrierColor,
            barrierDismissible: barrierDismissible,
            builder: builder,
          );
  }

  /// Shows a fun little bar of text at the bottom of the screen.
  void showSnackBar(SnackBar snackBar) =>
      ScaffoldMessenger.of(currentState.context).showSnackBar(snackBar);

  Future<void> logout() => resetLocalStorage().then(App.relaunch);
}
