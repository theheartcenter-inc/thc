import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/firebase/user.dart';
import 'package:thc/home/profile/account/account_field.dart';
import 'package:thc/home/profile/account/close_account.dart';
import 'package:thc/home/profile/profile.dart';
import 'package:thc/main.dart';
import 'package:thc/utils/navigator.dart';
import 'package:firebase_auth/firebase_auth.dart';

_showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Account Closed'),
      content: const Text('You have successfully closed your account.'),
      actions: [
        ElevatedButton(
          onPressed: () {
            // go back to the home page
            navigator.pushReplacement(const ChooseAnyView());
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  late TextEditingController _deleteController;

  @override
  void initState() {
    super.initState();
    AccountField.reset();
  }

  @override
  void dispose() {
    _deleteController.dispose(); // Dispose of the controller when done
    super.dispose();
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
        child: const Text('save changes'),
      ),
    );

    return PopScope(
      onPopInvoked: (_) => context.read<AccountFields>().emit(user!),
      child: Scaffold(
        appBar: AppBar(title: const Text('Account')),
        body: ProfileListView(
          itemCount: 4,
          itemBuilder: (_, index) => switch (index) {
            0 => Column(children: [...AccountField.values, saveButton]),
            1 => const ListTile(
                leading: Icon(Icons.lock_outline),
                title: Text('change password'),
                // onTap: () {},
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
