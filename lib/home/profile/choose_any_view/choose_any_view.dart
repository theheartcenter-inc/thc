import 'package:flutter/material.dart';
import 'package:thc/firebase/user.dart';
import 'package:thc/main.dart';
import 'package:thc/utils/app_config.dart';
import 'package:thc/utils/local_storage.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';

class ChooseAnyView extends StatelessWidget {
  const ChooseAnyView({super.key});

  const factory ChooseAnyView.button({Key? key}) = _ButtonFromLoginScreen;

  @override
  Widget build(BuildContext context) {
    const buttons = [null, ...UserType.values];
    const info = Text(
      'All data in local device storage will be cleared,\n'
      'and the app will relaunch as if you were logged in as the specified user type.',
      textAlign: TextAlign.center,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Choose any view!')),
      body: Center(
        child: Column(
          children: [
            const Spacer(flex: 5),
            for (final userType in buttons) ...[const Spacer(), UserButton(userType)],
            const Spacer(flex: 5),
            info,
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _ButtonFromLoginScreen extends ChooseAnyView {
  const _ButtonFromLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return IconButton.filled(
      style: IconButton.styleFrom(
        backgroundColor: colors.surface,
        foregroundColor: colors.outline,
      ),
      onPressed: () => navigator.push(const ChooseAnyView()),
      icon: const Icon(Icons.build),
    );
  }
}

class UserButton extends StatelessWidget {
  const UserButton(this.userType, {super.key});
  final UserType? userType;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () async {
        await clearLocalStorage();
        if (userType case final userType?) {
          await Future.wait([
            LocalStorage.loggedIn.save(true),
            LocalStorage.userId.save(userType.testId),
          ]);
          user = useInternet ? await ThcUser.download(userType.testId) : userType.testUser;
        } else {
          user = null;
        }
        App.relaunch();
      },
      style: FilledButton.styleFrom(
        backgroundColor: switch (userType) {
          null => context.lightDark(Colors.black26, Colors.white24),
          UserType.participant => ThcColors.green,
          UserType.director => ThcColors.teal,
          UserType.admin => ThcColors.tan,
        },
        foregroundColor: Colors.black,
      ),
      child: SizedBox(
        width: 150,
        child: Row(
          children: [
            Icon(switch (userType) {
              null => Icons.logout,
              UserType.participant => Icons.person,
              UserType.director => Icons.group,
              UserType.admin => Icons.groups,
            }),
            const SizedBox(width: 25, height: 50),
            Text(
              userType?.toString() ?? 'logged out',
              style: const StyleText(size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
