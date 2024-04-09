import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/firebase/user.dart';
import 'package:thc/home/profile/profile.dart';
import 'package:thc/utils/theme.dart';

class AccountField extends StatelessWidget {
  const AccountField(this.label, {this.value, required this.onChanged, super.key});
  final String label;
  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return ListTile(
      title: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: context.theme.textTheme.labelLarge),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                hintText: value ?? label,
                border: MaterialStateOutlineInputBorder.resolveWith((states) {
                  final focused = states.contains(MaterialState.focused);
                  return OutlineInputBorder(
                    borderSide: BorderSide(
                      color: focused ? colors.primary : colors.onBackground,
                      width: focused ? 2 : 1,
                    ),
                  );
                }),
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  String name = user!.name;
  String email = user?.email ?? '';
  String phone = user?.phoneNumber ?? '';

  bool somethingDifferent({bool listen = true}) {
    final user = Provider.of<EditingProfile>(context, listen: listen).state;
    return (name.isNotEmpty && name != user.name) ||
        (email.isNotEmpty && email != user.email) ||
        (phone.isNotEmpty && phone != user.phoneNumber);
  }

  void update() {
    if (!somethingDifferent(listen: false)) return;
    context.read<EditingProfile>().save(
          name: name.isEmpty ? null : name,
          email: email.isEmpty ? null : email,
          phoneNumber: phone.isEmpty ? null : phone,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ProfileListView(
        itemCount: 4,
        itemBuilder: (_, index) => switch (index) {
          0 => Column(children: [
              AccountField(
                'name',
                value: user!.name,
                onChanged: (value) => setState(() => name = value.trim()),
              ),
              AccountField(
                'email',
                value: user!.email,
                onChanged: (value) => setState(() => email = value.trim()),
              ),
              AccountField(
                'phone number',
                value: user!.phoneNumber,
                onChanged: (value) => setState(() => phone = value.trim()),
              ),
              FilledButton(
                onPressed: somethingDifferent() ? update : null,
                child: const Text('save changes'),
              ),
            ]),
          1 => const ListTile(title: Text('change password')),
          2 => const ListTile(title: Text('sign out')),
          _ => const ListTile(title: Text('close account')),
        },
      ),
    );
  }
}
