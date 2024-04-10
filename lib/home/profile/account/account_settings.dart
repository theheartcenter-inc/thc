import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/firebase/user.dart';
import 'package:thc/home/profile/profile.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/enum_widget.dart';

/// A [TextField] with a name that matches a [ThcUser.json] key.
enum AccountField with StatefulEnum {
  /// The user's first & last name (cannot be deleted).
  name,

  /// The user's email.
  ///
  /// (Eventually, we should probably verify the email whenever it's updated.)
  email,

  /// The user's phone number.
  ///
  /// (Eventually, we should probably verify the phone number whenever it's updated.)
  phone;

  /// The current values in the [TextField]s.
  static final List<String> textValues = List.filled(values.length, '');
  void update(String newText) => textValues[index] = newText.trim();

  /// The value of this field before any editing occurred.
  String? get current => switch (this) {
        name => user!.name,
        email => user!.email,
        phone => user!.phone,
      };

  /// The new [TextField] value that the user typed in.
  ///
  /// Set to `null` if it's empty or if it's unchanged.
  String? get updated {
    final text = textValues[index];
    return text.isNotEmpty && text != current ? text : null;
  }

  /// A [ThcUser] object, updated to match the current [TextField] content.
  static ThcUser get updatedUser => user!.copyWith(
        name: name.updated,
        email: email.updated,
        phone: phone.updated,
      );

  /// Changes all [textValues] to match the current [user].
  static void reset() {
    for (final value in values) {
      value.update(value.current ?? '');
    }
  }

  @override
  State<AccountField> createState() => _AccountFieldState();
}

class _AccountFieldState extends State<AccountField> {
  /// If this value is `true` (and the relevant value is non-null),
  /// a button will appear to remove (i.e. "yeet") the stored email or phone number.
  bool showYeetButton = false;
  late final TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController(text: widget.current);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    final style = MaterialStateTextStyle.resolveWith((states) => TextStyle(
          color: colors.onBackground.withOpacity(states.isFocused ? 1.0 : 0.5),
        ));
    final decoration = InputDecoration(
      isDense: true,
      labelText: widget.name,
      labelStyle: style,
      floatingLabelStyle: style,
      border: MaterialStateOutlineInputBorder.resolveWith((states) {
        return OutlineInputBorder(
          borderSide: states.isFocused
              ? BorderSide(color: colors.primary, width: 2)
              : BorderSide(color: colors.onBackground.withOpacity(0.5)),
        );
      }),
    );

    final Widget yeetButton;
    if (showYeetButton && (widget.current?.isNotEmpty ?? false)) {
      yeetButton = TextButton(
        onPressed: () async {
          await context.read<AccountFields>().yeet(widget);
          setState(() => widget.update(''));
        },
        style: TextButton.styleFrom(foregroundColor: colors.error),
        child: const Text('remove'),
      );
    } else {
      yeetButton = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: decoration,
              onChanged: (newText) {
                setState(() => showYeetButton = newText.isEmpty);
                context.read<AccountFields>().update(widget..update(newText));
              },
            ),
          ),
          AnimatedSize(
            duration: Durations.medium1,
            curve: Curves.ease,
            child: yeetButton,
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
  @override
  void initState() {
    AccountField.reset();
    super.initState();
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
                  builder: (_) => AlertDialog.adaptive(
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
            _ => const ListTile(
                leading: Icon(Icons.person_off_outlined),
                title: Text('close account'),
                // onTap: () {},
              ),
          },
        ),
      ),
    );
  }
}
