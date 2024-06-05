import 'package:thc/home/profile/account/account_field.dart';
import 'package:thc/home/profile/account/account_settings.dart';
import 'package:thc/home/profile/choose_any_view/choose_any_view.dart';
import 'package:thc/home/profile/info/heart_center_info.dart';
import 'package:thc/home/profile/report/issue_report.dart';
import 'package:thc/home/profile/settings/settings.dart';
import 'package:thc/the_good_stuff.dart';
import 'package:thc/utils/widgets/placeholders.dart';

enum ProfileOption with EnumStatelessWidgetMixin {
  account(
    Icons.person_rounded,
    action: AccountSettings(),
  ),

  settings(
    Icons.settings,
    action: SettingsScreen(),
  ),

  info(
    Icons.info_outline,
    label: 'about The Heart Center',
    action: HeartCenterInfo(),
  ),

  donate(
    Icons.favorite,
    action: HeartCenterInfo.donate,
  ),

  report(
    Icons.report_problem,
    label: 'report an issue / send feedback',
    action: IssueReport(),
  ),

  chooseAnyView(
    Icons.build,
    label: 'choose any view',
    action: ChooseAnyView(),
  );

  const ProfileOption(this.icon, {this.label, required this.action});
  final IconData icon;
  final String? label;

  /// Determines the behavior of `onTap()` in the [build] method below.
  final dynamic action;

  static final int count = values.length + (kDebugMode ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.only(left: 16);

    return ListTile(
      contentPadding: padding,
      leading: Icon(icon),
      title: Padding(padding: padding, child: Text(label ?? name)),
      trailing: const Icon(Icons.chevron_right),
      onTap: switch (action) {
        VoidCallback() => action,
        Widget() => () => navigator.push(action),
        _ => throw TypeError(),
      },
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userWatch = context.watch<AccountFields>().value ?? ThcUser(name: 'Not Found', id: '');
    assert(userWatch.name != 'Not Found', "couldn't get AccountFields data");

    final Color link = Color.lerp(ThcColors.dullBlue, ThcColors.teal, 0.25)!;
    final overview = DefaultTextStyle(
      style: TextStyle(height: 1.75, color: ThcColors.of(context).onSurface),
      child: Center(
        child: Column(
          children: [
            const PlaceholderImage(width: 100),
            Text(userWatch.name, style: const TextStyle(size: 28)),
            if (user.id case final id?) Text('user ID: $id', style: const TextStyle(weight: 600)),
            if (userWatch.email case final email?) Text(email, style: TextStyle(color: link)),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );

    return ProfileListView(
      itemCount: ProfileOption.count,
      itemBuilder: (_, index) => switch (index - 1) {
        -1 => overview,
        final int i => ProfileOption.values[i],
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
