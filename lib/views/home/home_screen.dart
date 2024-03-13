import 'package:flutter/material.dart';
import 'package:thc/models/local_storage.dart';
import 'package:thc/models/user.dart';
import 'package:thc/views/home/admin_home.dart';
import 'package:thc/views/home/director_home.dart';
import 'package:thc/views/home/participant_home.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// Using this `=>` syntax makes things look nice:
  ///
  /// ```dart
  /// // these two functions are equivalent
  /// Color bestColor() {
  ///   return Color(0xff00ffff);
  /// }
  /// Color bestColor() => Color(0xff00ffff);
  /// ```
  ///
  /// But for most [build] methods, it's better to use the curly braces,
  /// since they don't indent the function as much and it's easier
  /// to add in more stuff if you need to.
  @override
  Widget build(BuildContext context) => switch (userType) {
        UserType.participant => const ParticipantHomeScreen(),
        UserType.director => const DirectorHomeScreen(),
        UserType.admin => const AdminHomeScreen(),
      };
}
