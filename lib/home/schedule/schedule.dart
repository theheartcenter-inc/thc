import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/home/schedule/edit_schedule/schedule_editor.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';

class Schedule extends StatelessWidget {
  const Schedule({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    Widget? editButton;
    if (user.isAdmin) {
      editButton = IconButton.filled(
        icon: const Icon(Icons.edit),
        onPressed: () => navigator.push(const ScheduleEditor()),
      );
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Text(
                'Active Livestream',
                style: StyleText(
                  size: 24.0,
                  color: colors.inverseSurface,
                  weight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: ThcColors.green,
                margin: const EdgeInsets.all(8.0),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  onTap: () {
                    context.read<NavBarIndex>().selectButton(NavBarButton.watchLive);
                  },
                  hoverColor: ThcColors.darkGreen.withOpacity(1 / 8),
                  leading: const FlutterLogo(size: 56.0),
                  title: const Text(
                    'Active Livestream',
                    style: StyleText(color: Colors.black),
                  ),
                  subtitle: const Text(
                    'April 3, 2024 12:00PM EST',
                    style: StyleText(color: Colors.black),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Upcoming Livestreams',
                style: StyleText(
                  size: 24.0,
                  color: colors.inverseSurface,
                  weight: FontWeight.bold,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    color: ThcColors.green,
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: FlutterLogo(size: 56.0),
                      title: Text(
                        'Upcoming Livestream A',
                        style: StyleText(color: Colors.black),
                      ),
                      subtitle: Text(
                        'June 5, 2024 7:00PM EST',
                        style: StyleText(color: Colors.black),
                      ),
                    ),
                  ),
                  Card(
                    color: ThcColors.green,
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: FlutterLogo(size: 56.0),
                      title: Text(
                        'Upcoming Livestream B',
                        style: StyleText(color: Colors.black),
                      ),
                      subtitle: Text(
                        'June 10, 2024 7:00PM EST',
                        style: StyleText(color: Colors.black),
                      ),
                    ),
                  ),
                  Card(
                    color: ThcColors.green,
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: FlutterLogo(size: 56.0),
                      title: Text(
                        'Upcoming Livestream C',
                        style: StyleText(color: Colors.black),
                      ),
                      subtitle: Text(
                        'June 15, 2024 12:00PM EST',
                        style: StyleText(color: Colors.black),
                      ),
                    ),
                  ),
                  Card(
                    color: ThcColors.green,
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: FlutterLogo(size: 56.0),
                      title: Text(
                        'Upcoming Livestream D',
                        style: StyleText(color: Colors.black),
                      ),
                      subtitle: Text(
                        'June 20, 2024 2:00PM EST',
                        style: StyleText(color: Colors.black),
                      ),
                    ),
                  ),
                  Card(
                    color: ThcColors.green,
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: FlutterLogo(size: 56.0),
                      title: Text(
                        'Upcoming Livestream E',
                        style: StyleText(color: Colors.black),
                      ),
                      subtitle: Text(
                        'June 25, 2024 4:00PM EST',
                        style: StyleText(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: editButton,
    );
  }
}
