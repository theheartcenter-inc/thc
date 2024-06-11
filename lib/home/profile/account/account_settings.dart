import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/home/profile/account/account_field.dart';
import 'package:thc/home/profile/account/change_password.dart';
import 'package:thc/home/profile/account/close_account.dart';
import 'package:thc/home/profile/profile.dart';
import 'package:thc/utils/local_storage.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile picture: $e')),
      );
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
        child: const Text('Save Changes', style: TextStyle(weight: 520)),
      ),
    );

    return PopScope(
      onPopInvoked: (_) => context.read<AccountFields>().value = user,
      child: Scaffold(
        appBar: AppBar(title: const Text('Account')),
        body: ProfileListView(
          itemCount: 5, // Increased the itemCount to 5 to include the profile picture section
          itemBuilder: (_, index) {
            switch (index) {
              case 0:
                return Column(children: [...AccountField.values, saveButton]);
              case 1:
                if (user.type == UserType.director || user.type == UserType.admin) {
                  return ListTile(
                    leading: const Icon(Icons.image),
                    title: const Text('Change Profile Picture'),
                    onTap: () => _updateProfilePicture(user),
                  );
                }
                return const SizedBox.shrink(); // Hide this item for participants
              case 2:
                return ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change Password'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                  ),
                );
              case 3:
                return ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sign Out'),
                  onTap: () async {
                    final signOut = await showDialog<bool>(
                      context: context,
                      builder: (context) => const AlertDialog(
                        title: Text('Sign Out'),
                        content: Text('Are you sure you want to sign out?\n'
                            "You'll need to enter your email & password to sign back in."),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Sign Out'),
                          ),
                        ],
                      ),
                    ) ?? false;

                    if (signOut == true) {
                      // Perform sign-out logic here
                    }
                  },
                );
              case 4:
                return ListTile(
                  leading: const Icon(Icons.person_off_outlined),
                  title: const Text('Close Account'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CloseAccountScreen()),
                  ),
                );
              default:
                return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }
}
