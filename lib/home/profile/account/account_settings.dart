import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/home/profile/account/account_field.dart';
import 'package:thc/home/profile/account/change_password.dart';
import 'package:thc/home/profile/account/close_account.dart';
import 'package:thc/home/profile/profile.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/style_text.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  @override
  void initState() {
    super.initState();
    AccountField.reset();
  }

  @override
  Widget build(BuildContext context) {
    final saveButton = Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: FilledButton(
        onPressed: context.watch<AccountFields>().hasChanges
            ? () {
                context.read<AccountFields>().save(AccountField.updatedUser);
                setState(AccountField.reset);
              }
            : null,
        child: const Text('save changes', style: StyleText(weight: 520)),
      ),
    );

    return PopScope(
      onPopInvoked: (_) => context.read<AccountFields>().value = user,
      child: Scaffold(
        appBar: AppBar(title: const Text('Account')),
        body: ProfileListView(
          itemCount: 4,
          itemBuilder: (_, index) => switch (index) {
            0 => Column(children: [...AccountField.values, saveButton]),
            1 => ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('change password'),
                onTap: () => navigator.showDialog(
                  AlertDialog.adaptive(
                    title: const Text('Change Password'),
                    content: const Text(
                      'Are you sure you want to change the password?\n'
                      "You'll need to enter your current password & new password to change.",
                    ),
                    actions: [
                      ElevatedButton(onPressed: navigator.pop, child: const Text('No')),
                      ElevatedButton(
                        onPressed: () => navigator
                          ..pop()
                          ..push(const ChangePasswordScreen()),
                        child: const Text('Yes'),
                      ),
                    ],
                    actionsAlignment: MainAxisAlignment.spaceEvenly,
                  ),
                ),
              ),
            2 => ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('sign out'),
                onTap: () => navigator.showDialog(
                  AlertDialog.adaptive(
                    title: const Text('sign out'),
                    content: const Text(
                      'Are you sure you want to sign out?\n'
                      "You'll need to enter your email & password to sign back in.",
                    ),
                    actions: [
                      ElevatedButton(onPressed: navigator.pop, child: const Text('back')),
                      ElevatedButton(onPressed: navigator.logout, child: const Text('sign out')),
                    ],
                    actionsAlignment: MainAxisAlignment.spaceEvenly,
                  ),
                ),
              ),
            _ => ListTile(
                leading: const Icon(Icons.person_off_outlined),
                title: const Text('close account'),
                onTap: () => navigator.showDialog(const CloseAccount()),
              ),
          },
        ),
      ),
    );
  }
}
