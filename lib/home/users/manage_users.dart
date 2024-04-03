import 'package:flutter/material.dart';
import 'package:thc/utils/widgets/fun_placeholder.dart';

class ManageUsers extends StatelessWidget {
  const ManageUsers({super.key});

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
  Widget build(BuildContext context) =>
      const FunPlaceholder('User Management (add/remove users & assign permissions)!');
}
