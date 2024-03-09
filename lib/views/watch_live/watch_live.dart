import 'package:flutter/material.dart';
import 'package:thc/views/widgets.dart';

class WatchLive extends StatelessWidget {
  const WatchLive({super.key});

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
  Widget build(BuildContext context) => const FunPlaceholder('watch a livestream!');
}
