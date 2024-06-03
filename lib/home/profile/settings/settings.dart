import 'package:flutter/material.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/utils/bloc.dart';
import 'package:thc/utils/local_storage.dart';
import 'package:thc/utils/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Dark theme?', style: StyleText(size: 20)),
            const SizedBox(height: 20),
            const _ThemePicker(),
            if (user.isAdmin) ...const [
              SizedBox(height: 50),
              NavBarSwitch(LocalStorage.adminWatchLive),
              NavBarSwitch(LocalStorage.adminStream),
            ],
          ],
        ),
      ),
    );
  }
}

class NavBarSwitch extends HookWidget {
  const NavBarSwitch(this.storageKey, {super.key});
  final LocalStorage storageKey;

  @override
  Widget build(BuildContext context) {
    final state = useState<bool>(storageKey());

    return SwitchListTile.adaptive(
      title: Text(switch (storageKey) {
        LocalStorage.adminWatchLive => 'show "watch live"',
        LocalStorage.adminStream || _ => 'show "stream"',
      }),
      value: state.value,
      onChanged: (newValue) {
        state.toggle();
        storageKey.save(newValue);
        context.read<NavBarSelection>().refresh();
      },
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ThemeMode>(
      showSelectedIcon: false,
      segments: [
        for (final value in ThemeMode.values)
          ButtonSegment(
            value: value,
            label: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(value.name),
            ),
          ),
      ],
      selected: {context.watch<AppTheme>().value},
      onSelectionChanged: (selection) => context.read<AppTheme>().newThemeMode(selection.first),
    );
  }
}
