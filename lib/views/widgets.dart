import 'package:flutter/material.dart';
import 'package:thc/models/theme.dart';

class FunPlaceholder extends StatelessWidget {
  const FunPlaceholder(this.label, {this.color, super.key});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final color = this.color ?? colorScheme.primary;
    final style = TextStyle(
      color: color,
      fontFamily: 'Consolas',
      fontFamilyFallback: const ['Courier New', 'Courier', 'monospace'],
      fontSize: 32,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(color: colorScheme.background.withOpacity(0.5), blurRadius: 2),
      ],
    );

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(label, textAlign: TextAlign.center, style: style),
      ),
    );
  }
}

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
  void animate() {}

  @override
  void initState() {
    super.initState();
    animate();
  }
}
