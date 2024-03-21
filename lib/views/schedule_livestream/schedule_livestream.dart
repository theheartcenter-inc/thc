import 'package:flutter/material.dart';
import 'package:thc/views/widgets.dart';
import 'package:thc/models/theme.dart';

class ScheduleLivestream extends StatelessWidget {
  const ScheduleLivestream({super.key});

  /// The following two functions are equivalent:
  /// ```dart
  /// bool function() { return true; }
  /// bool function() => true;
  /// ```
  ///
  /// `=>` definitely looks nice, but usually it's not recommended
  /// for methods like [build], since no function body means
  /// you can't just quickly add stuff in when you need to.
  @override
  Widget build(BuildContext context) => const FunPlaceholder('schedule a livestream!');
}
