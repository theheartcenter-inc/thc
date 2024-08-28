import 'package:thc/firebase/firebase.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/the_good_stuff.dart';

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
            const Text('Dark theme?', style: TextStyle(size: 20)),
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
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    if(value == true){
      await Firestore.users.doc(user.id ?? user.email!).update({'fcmToken': token});
      await FirebaseMessaging.instance.subscribeToTopic("livestream_notifications");
    }
    if(value == false){
      await Firestore.users.doc(user.id ?? user.email!).update({'fcmToken': ''});
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
