import 'package:flutter/material.dart';

/// [StateAsync] can be used instead of the regular [State]
/// when you're using timers/delays for state management.
abstract class StateAsync<T extends StatefulWidget> extends State<T> {
  /// ```dart
  ///
  /// await sleep(3); // inside an async function
  /// sleep(3, then: () => doSomething()); // use this anywhere!
  /// ```
  Future<void> sleep(double seconds, {VoidCallback? then}) =>
      Future.delayed(Duration(milliseconds: (seconds * 1000).round()), then);

  /// If you do something like this:
  ///
  /// ```dart
  /// sleep(3, then: setState(() => _value = newValue));
  /// ```
  ///
  /// it can cause a crash if the widget is removed during those 3 seconds.
  ///
  /// Checking the [mounted] property first will prevent this issue,
  /// but keep in mind that it also makes stuff like infinite loops
  /// and memory leaks more difficult to catch.
  void safeState(VoidCallback fn) => mounted ? setState(fn) : null;

  /// [sleep], then [setState].
  ///
  /// (These are combined pretty often, so this function makes things convenient.)
  Future<void> sleepState(double seconds, VoidCallback fn) =>
      sleep(seconds, then: () => safeState(fn));

  /// {@template views.widgets.StateAsync.animate}
  /// Putting `async` code in the [initState] doesn't work super great.
  ///
  /// So use [animate] instead!
  ///
  /// ```dart
  /// @override
  /// void animate() async {
  ///   // ...
  /// }
  /// ```
  /// {@endtemplate}
  void animate() {}

  /// {@macro views.widgets.StateAsync.animate}
  @override
  void initState() {
    super.initState();
    animate();
  }
}
