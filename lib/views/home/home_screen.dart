import 'package:flutter/material.dart';
import 'package:thc/models/local_storage.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/models/user.dart';
import 'package:thc/views/admin_portal/admin_portal.dart';
import 'package:thc/views/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => switch (userType) {
        UserType.participant => const ParticipantHomeScreen(),
        UserType.director => const DirectorHomeScreen(),
        UserType.admin => const AdminPortal(),
      };
}

class ParticipantHomeScreen extends StatelessWidget {
  const ParticipantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FunPlaceholder('Home screen for participants!');
  }
}

class DirectorHomeScreen extends StatelessWidget {
  const DirectorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FunPlaceholder('Home screen for directors!', color: context.colorScheme.secondary);
  }
}
