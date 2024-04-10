import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/firebase/user.dart';
import 'package:thc/home/profile/account/account_settings.dart';
import 'package:thc/home/profile/info/heart_center_info.dart';
import 'package:thc/home/profile/report/issue_report.dart';
import 'package:thc/home/profile/settings/settings.dart';
import 'package:thc/utils/bloc.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/widgets/enum_widget.dart';
import 'package:url_launcher/url_launcher.dart';

enum ProfileOption with StatelessEnum {
  account(
    Icons.person_rounded,
    page: AccountSettings(),
  ),

  settings(
    Icons.settings,
    page: SettingsScreen(),
  ),

  info(
    Icons.info_outline,
    label: 'about The Heart Center',
    page: HeartCenterInfo(),
  ),

  donate(Icons.favorite),

  report(
    Icons.report_problem,
    label: 'report an issue / send feedback',
    page: IssueReport(),
  ),

  logout(Icons.logout, label: 'sign out');

  const ProfileOption(this.icon, {this.label, this.page});
  final IconData icon;
  final String? label;
  final Widget? page;

  VoidCallback get onTap => switch (this) {
        account || settings || info || report => () => navigator.push(page!),
        donate => () => launchUrl(
              Uri.parse('https://secure.givelively.org/donate/heart-center-inc'),
            ),
        logout => () => navigator.showDialog(
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
      };

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.only(left: 16);

    return ListTile(
      contentPadding: padding,
      leading: Icon(icon),
      title: Padding(padding: padding, child: Text(label ?? name)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const image = Padding(
      padding: EdgeInsets.all(10),
      child: SizedBox(
        width: 100,
        height: 100,
        child: ClipOval(
          child: FittedBox(
            fit: BoxFit.cover,
            child: Image(image: AssetImage('assets/profile_placeholder.jpg')),
          ),
        ),
      ),
    );

    if (user == null) throw Exception('The value of "user" isn\'t set.');

    final userWatch = context.watch<AccountFields>().state;

    final overview = DefaultTextStyle(
      style: const TextStyle(height: 2),
      child: Center(
        child: Column(
          children: [
            image,
            Text(userWatch.name, style: const TextStyle(fontSize: 28)),
            if (user!.id case final id?)
              Text('user ID: $id', style: const TextStyle(fontWeight: FontWeight.w600)),
            if (userWatch.email case final email?) Opacity(opacity: 0.5, child: Text(email)),
            if (userWatch.phone case final phone?) Opacity(opacity: 0.75, child: Text(phone)),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );

    return ProfileListView(
      itemCount: ProfileOption.values.length + 1,
      itemBuilder: (_, index) => switch (index - 1) {
        -1 => overview,
        final i => ProfileOption.values[i],
      },
    );
  }
}

class ProfileListView extends StatelessWidget {
  const ProfileListView({required this.itemCount, required this.itemBuilder, super.key});
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              itemBuilder: itemBuilder,
              separatorBuilder: (_, __) => const Divider(),
            ),
          ),
        ),
      ),
    );
  }
}

class AccountFields extends Cubit<ThcUser> {
  AccountFields() : super(user!);

  void update(AccountField field) => emit(AccountField.updatedUser);

  bool get hasChanges => AccountField.values.any((value) => value.updated != null);

  Future<void> save(ThcUser updatedUser) async {
    await updatedUser.upload();
    emit(user = updatedUser);
  }

  Future<void> yeet(AccountField field) async {
    final data = user!.json..remove(field.name);
    await save(ThcUser.fromJson(data));
  }
}
