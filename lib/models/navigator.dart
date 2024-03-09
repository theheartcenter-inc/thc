import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
Nav get navigator => Nav(navKey.currentState!);

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
