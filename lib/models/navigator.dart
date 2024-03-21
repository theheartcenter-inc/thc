import 'package:flutter/material.dart';

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

/// {@macro models.navigator}
extension type Nav(NavigatorState navigator) {
  /// if you call [push], you'll navigate to a new widget,
  /// and calling [pop] will take you back to where you came from.
  Future<T?> push<T>(Widget destination) =>
      navigator.push<T>(MaterialPageRoute<T>(builder: (context) => destination));

  /// if you call [pushReplacement], you'll navigate to a new widget,
  /// and calling [pop] won't do anything.
  Future<void> pushReplacement(Widget destination) => navigator.pushReplacement<void, void>(
        MaterialPageRoute<void>(builder: (context) => destination),
      );

  void pop<T>([T? value]) => navigator.maybePop<T>(value);
}
