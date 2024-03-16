import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/models/bloc.dart';
import 'package:thc/models/local_storage.dart';
import 'package:thc/models/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Dark theme?', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            _ThemePicker(),
          ],
        ),
      ),
    );
  }
}

class AppTheme extends Cubit<ThemeMode> {
  AppTheme() : super(StorageKeys.themeMode());

  void newThemeMode(ThemeMode newTheme) {
    StorageKeys.themeMode.save(newTheme.index);
    emit(newTheme);
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppTheme>().state;
    final style = TextStyle(color: context.colorScheme.onBackground);
    return SegmentedButton<ThemeMode>(
      style: SegmentedButton.styleFrom(
        side: const BorderSide(style: BorderStyle.none),
        backgroundColor: context.lightDark(Colors.white54, Colors.black54),
      ),
      showSelectedIcon: false,
      segments: [
        for (final value in ThemeMode.values)
          ButtonSegment(
            value: value,
            label: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
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
