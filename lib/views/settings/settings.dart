import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thc/models/local_storage.dart';
import 'package:thc/models/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Dark theme?',
              style: TextStyle(fontSize: 20, color: context.colorScheme.onBackground),
            ),
            const SizedBox(height: 20),
            const _ThemePicker(),
          ],
        ),
      ),
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppTheme>().state;
    final style = TextStyle(color: context.colorScheme.onBackground);
    return SegmentedButton<ThemeMode>(
      showSelectedIcon: false,
      segments: [
        for (final value in ThemeMode.values)
          ButtonSegment(
            value: value,
            label: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                value.name,
                style: themeMode == value ? null : style,
              ),
            ),
          ),
      ],
      selected: {themeMode},
      onSelectionChanged: (selection) => context.read<AppTheme>().newThemeMode(selection.first),
    );
  }
}
