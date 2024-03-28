import 'package:flutter/material.dart';
import 'package:thc/models/enum_widget.dart';
import 'package:thc/models/navigation.dart';
import 'package:thc/views/profile/edit_profile.dart';
import 'package:thc/views/profile/heart_center_info.dart';
import 'package:thc/views/profile/issue_report.dart';
import 'package:thc/views/profile/settings.dart';

enum ProfileOptions with StatelessEnum {
  edit(
    icon: Icons.edit,
    label: 'Edit profile',
    page: EditProfile(),
  ),
  settings(
    icon: Icons.settings,
    label: 'Settings',
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
  );

  const ProfileOptions({required this.icon, required this.label, required this.page});
  final IconData icon;
  final String label;
  final Widget page;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.only(left: 16);

    return ListTile(
      contentPadding: padding,
      leading: Icon(icon),
      title: Padding(padding: padding, child: Text(label)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => navigator.push(page),
    );
  }
}

class ProfilesScreen extends StatelessWidget {
  const ProfilesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    const image = SizedBox(
      width: 100,
      height: 100,
      child: ClipOval(
        child: FittedBox(
          fit: BoxFit.cover,
          child: Image(image: AssetImage('assets/test.png')),
        ),
      ),
    );

    const overview = Center(
      child: Column(
        children: [
          SizedBox(height: 25),
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
              itemCount: ProfileOptions.values.length + 1,
              separatorBuilder: (_, index) => const Divider(),
              itemBuilder: (_, index) => switch (index - 1) {
                -1 => overview,
                final i => ProfileOptions.values[i],
              },
            ),
          ),
        ),
      ),
    );
  }
}
