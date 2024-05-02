import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/home/profile/account/account_field.dart';
import 'package:thc/home/profile/account/account_settings.dart';
import 'package:thc/home/profile/choose_any_view/choose_any_view.dart';
import 'package:thc/home/profile/info/heart_center_info.dart';
import 'package:thc/home/profile/report/issue_report.dart';
import 'package:thc/home/profile/settings/settings.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/enum_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

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

  chooseAnyView(
    Icons.build,
    label: 'choose any view',
    page: ChooseAnyView(),
  );

  const ProfileOption(this.icon, {this.label, this.page});
  final IconData icon;
  final String? label;
  final Widget? page;

  static final count = values.length + (kDebugMode ? 1 : 0);

  VoidCallback get onTap => switch (this) {
        donate => () => launchUrlString('https://secure.givelively.org/donate/heart-center-inc'),
        account || settings || info || report || chooseAnyView => () => navigator.push(page!),
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

    final userWatch = context.watch<AccountFields>().state ??
        ThcUser(name: 'Not Found', type: UserType.participant, id: '');
    final linkColor = Color.lerp(ThcColors.dullBlue, ThcColors.teal, 0.25)!;
    final overview = DefaultTextStyle(
      style: StyleText(height: 1.75, color: context.colorScheme.onBackground),
      child: Center(
        child: Column(
          children: [
            image,
            Text(userWatch.name, style: const StyleText(size: 28)),
            if (user.id case final id?) Text('user ID: $id', style: const StyleText(weight: 600)),
            if (userWatch.email case final email?)
              Text(email, style: StyleText(color: linkColor)),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );

    return ProfileListView(
      itemCount: ProfileOption.count,
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
