import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/utils/local_storage.dart';
import 'package:thc/utils/style_text.dart';
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
            const SizedBox(height: 50),
            const NotificationSwitch(LocalStorage.notify),
          ],
        ),
      ),
    );
  }
}

class NavBarSwitch extends StatefulWidget {
  const NavBarSwitch(this.storageKey, {super.key});
  final LocalStorage storageKey;

  @override
  State<NavBarSwitch> createState() => _NavBarSwitchState();
}

class _NavBarSwitchState extends State<NavBarSwitch> {
  late bool value = widget.storageKey();
  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      title: Text(switch (widget.storageKey) {
        LocalStorage.adminWatchLive => 'show "watch live"',
        LocalStorage.adminStream || _ => 'show "stream"',
      }),
      value: value,
      onChanged: (newValue) {
        setState(() => value = newValue);
        widget.storageKey.save(newValue);
        context.read<NavBarSelection>().refresh();
      },
    );
  }
}

class NotificationSwitch extends StatefulWidget {
  const NotificationSwitch(this.storageKey, {super.key});
  final LocalStorage storageKey;

  @override
  State<NotificationSwitch> createState() => _NotificationSwitchState();
}

class _NotificationSwitchState extends State<NotificationSwitch> {
  @override
  Future<void> _updateUserPreference(bool? value) async {
    await Firestore.users.doc(user.id ?? user.email!).update({'notify': value});
    if(value == true){
      await FirebaseMessaging.instance.subscribeToTopic("livestream_notifications");
    }
    if(value == false){
      await FirebaseMessaging.instance.unsubscribeFromTopic("livestream_notifications");
    }
  }

  @override
  Widget build(BuildContext context) {
    late bool value = widget.storageKey() ?? user.notify ?? false;
    return SwitchListTile(
      title: const Text('Enable Livestream Notifications'),
      value: value,
      onChanged: (bool newValue) {
        setState(() => value = newValue);
        widget.storageKey.save(value);
        context.read<NavBarSelection>().refresh();
        _updateUserPreference(value);
      },
    );
  }
}

class _ThemePicker extends StatelessWidget {
  const _ThemePicker();

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppTheme>().value;
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
      selected: {themeMode},
      onSelectionChanged: (selection) => context.read<AppTheme>().newThemeMode(selection.first),
    );
  }
}
