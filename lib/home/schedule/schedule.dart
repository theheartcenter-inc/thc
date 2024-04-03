import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/home/schedule/edit_schedule/schedule_editor.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/user.dart';

class Schedule extends StatelessWidget {
  const Schedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livestream Schedule'),
        actions: [
          if (userType.isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => navigator.push(const ScheduleEditor()),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: Text(
                'Active Livestream',
                style: TextStyle(
                  fontSize: 24.0,
                  color: ThcColors.darkBlue,
                  fontWeight: FontWeight.bold,
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
                  title: const Text('Active Livestream'),
                  subtitle: const Text('April 3, 2024 12:00PM EST'),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Upcoming Livestreams',
                style: TextStyle(
                  fontSize: 24.0,
                  color: ThcColors.darkBlue,
                  fontWeight: FontWeight.bold,
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
                      title: Text('Upcoming Livestream A'),
                      subtitle: Text('June 5, 2024 7:00PM EST'),
                    ),
                  ),
                  Card(
                    color: ThcColors.green,
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: FlutterLogo(size: 56.0),
                      title: Text('Upcoming Livestream B'),
                      subtitle: Text('June 10, 2024 7:00PM EST'),
                    ),
                  ),
                  Card(
                    color: ThcColors.green,
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: FlutterLogo(size: 56.0),
                      title: Text('Upcoming Livestream C'),
                      subtitle: Text('June 15, 2024 12:00PM EST'),
                    ),
                  ),
                  Card(
                    color: ThcColors.green,
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: FlutterLogo(size: 56.0),
                      title: Text('Upcoming Livestream D'),
                      subtitle: Text('June 20, 2024 2:00PM EST'),
                    ),
                  ),
                  Card(
                    color: ThcColors.green,
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: FlutterLogo(size: 56.0),
                      title: Text('Upcoming Livestream E'),
                      subtitle: Text('June 25, 2024 4:00PM EST'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
