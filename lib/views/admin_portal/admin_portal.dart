import 'package:flutter/material.dart';
import 'package:thc/models/navigator.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/settings/settings.dart';
import 'package:thc/views/widgets.dart';

class AdminPortal extends StatelessWidget {
  const AdminPortal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          onPressed: () => navigator.push(const SettingsScreen()),
          icon: const Icon(Icons.settings),
        ),
      ]),
      body: FunPlaceholder('admin portal', color: context.colorScheme.inverseSurface),
    );
  }
}
