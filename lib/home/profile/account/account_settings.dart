import 'package:thc/home/profile/account/account_field.dart';
import 'package:thc/home/profile/account/change_password.dart';
import 'package:thc/home/profile/account/close_account.dart';
import 'package:thc/home/profile/profile.dart';
import 'package:thc/the_good_stuff.dart';

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

  Future<void> _updateProfilePicture(ThcUser user) async {
    try {
      await user.updateProfilePicture();
      setState(() {});
      navigator.snackbarMessage('Profile picture updated successfully');
    } catch (e) {
      navigator.snackbarMessage('Failed to update profile picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<ThcUser?>(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Account')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final saveButton = Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: FilledButton(
        onPressed: context.watch<AccountFields>().hasChanges
            ? () {
                context.read<AccountFields>().save(AccountField.updatedUser);
                setState(AccountField.reset);
              }
            : null,
        child: const Text('save changes', style: TextStyle(weight: 520)),
      ),
    );

    return PopScope(
      onPopInvoked: (_) => context.read<AccountFields>().value = user,
      child: Scaffold(
        appBar: AppBar(title: const Text('Account')),
        body: ProfileListView(
          itemCount: 4,
          itemBuilder: (_, index) => switch (index) {
            0 => Column(children: [
                ...AccountField.values,
                saveButton,
                if (user.canLivestream)
                  ListTile(
                    leading: const Icon(Icons.image),
                    title: const Text('Change Profile Picture'),
                    onTap: () => _updateProfilePicture(user),
                  ),
              ]),
            1 => ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('change password'),
                onTap: () => navigator.push(const ChangePasswordScreen()),
              ),
            2 => ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('sign out'),
                onTap: () async {
                  final signOut = await navigator.showDialog(
                    const Dialog.confirm(
                      titleText: 'sign out',
                      bodyText: 'Are you sure you want to sign out?\n'
                          "You'll need to enter your email & password to sign back in.",
                      actionText: ('back', 'sign out'),
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                    ),
                  );

                  if (signOut) navigator.logout();
                },
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
