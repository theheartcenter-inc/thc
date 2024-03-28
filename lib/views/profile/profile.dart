import 'package:flutter/material.dart';
import 'package:thc/models/enum_widget.dart';
import 'package:thc/models/navigator.dart';
import 'package:thc/views/login_register/login.dart';
import 'package:thc/views/profile/edit_profile.dart';
import 'package:thc/views/profile/heart_center_info.dart';
import 'package:thc/views/profile/issue_report.dart';
import 'package:thc/views/profile/settings.dart';

enum ProfileOption with StatelessEnum {
  edit(
    icon: Icons.edit,
    label: 'edit profile',
    page: EditProfile(),
  ),
  settings(
    icon: Icons.settings,
    label: 'settings',
    page: SettingsScreen(),
  ),
  info(
    icon: Icons.info_outline,
    label: 'about The Heart Center',
    page: HeartCenterInfo(),
  ),
  report(
    icon: Icons.report_problem,
    label: 'report an issue',
    page: IssueReport(),
  ),
  logout(
    icon: Icons.logout,
    label: 'sign out',
    page: LoginScreen(),
  );

  const ProfileOption({required this.icon, required this.label, required this.page});
  final IconData icon;
  final String label;
  final Widget page;

  VoidCallback get onTap => switch (this) {
        edit || settings || info || report => () => navigator.push(page),
        logout => () {
            navigator.showDialog(
              builder: (context) => AlertDialog.adaptive(
                title: const Text('sign out'),
                content: const Text(
                  'Are you sure you want to sign out?\n'
                  "You'll need to enter your email & password to sign back in.",
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () => navigator.pop(),
                    child: const Text('back'),
                  ),
                  ElevatedButton(
                    onPressed: () => navigator.push(page),
                    child: const Text('sign out'),
                  ),
                ],
                actionsAlignment: MainAxisAlignment.spaceEvenly,
              ),
            );
          },
      };

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.only(left: 16);

    return ListTile(
      contentPadding: padding,
      leading: Icon(icon),
      title: Padding(padding: padding, child: Text(label)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class ProfilesScreen extends StatelessWidget {
  const ProfilesScreen({super.key});
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
            child: Image(image: AssetImage('assets/test.png')),
          ),
        ),
      ),
    );

    const overview = Center(
      child: Column(
        children: [
          image,
          Text('First Lastname', style: TextStyle(fontSize: 28)),
          SizedBox(height: 5),
          Text('username: [username]', style: TextStyle(fontWeight: FontWeight.w600)),
          Opacity(opacity: 0.5, child: Text('email.address@gmail.com')),
          SizedBox(height: 25),
        ],
      ),
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView.separated(
              itemCount: ProfileOption.values.length + 1,
              separatorBuilder: (_, index) => const Divider(),
              itemBuilder: (_, index) => switch (index - 1) {
                -1 => overview,
                final i => ProfileOption.values[i],
              },
            ),
          ),
        ),
      ),
    );
  }
}
