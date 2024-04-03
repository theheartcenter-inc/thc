import 'package:flutter/material.dart';
import 'package:thc/models/navigator.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/models/user.dart';
import 'package:thc/views/manage_schedule/manage_schedule.dart';

class Schedule extends StatelessWidget {
  const Schedule({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livestream Schedule'),
        backgroundColor: ThcColors.darkBlue,
        actions: [
          Visibility(
            visible: userType.isAdmin,
            child: IconButton(
              icon: const Icon(Icons.add), // Choose your desired icon
              onPressed: () {
                // Add your onPressed callback function here
                // This function will be called when the icon button is clicked
                navigator.push(const ManageSchedule());
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // First Header
            Container(
              margin: const EdgeInsets.only(top: 16.0),
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'Active Livestreams',
                style: TextStyle(
                  fontSize: 24.0,
                  color: ThcColors.darkBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // First ListView inside a Card
            Container(
              margin: const EdgeInsets.all(16.0),
              child: const Column(
                children: [
                  Card(
                    color: ThcColors.green,
                    margin: EdgeInsets.all(8.0), // Set margins for all sides
                    child: ListTile(
                      leading: FlutterLogo(size: 56.0),
                      title: Text('Active Livestream'),
                      subtitle: Text('April 3, 2024 12:00PM EST'),
                    ),
                  ),
                  // Add more ListTiles as needed
                ],
              ),
            ),
            // Second Header
            Container(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'Upcoming Livestreams',
                style: TextStyle(
                  fontSize: 24.0,
                  color: ThcColors.darkBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Second ListView inside a Card
            Container(
              margin: const EdgeInsets.all(16.0),
              child: const Column(
                children: [
                  Card(
                    color: ThcColors.green,
                    margin: EdgeInsets.all(8.0), // Set margins for all sides
                    child: ListTile(
                      leading: FlutterLogo(size: 56.0),
                      title: Text('Upcoming Livestream A'),
                      subtitle: Text('June 5, 2024 7:00PM EST'),
                    ),
                  ),
                  Card(
                    color: ThcColors.green,
                    margin: EdgeInsets.all(8.0), // Set margins for all sides
                    child: ListTile(
                      leading: FlutterLogo(size: 56.0),
                      title: Text('Upcoming Livestream B'),
                      subtitle: Text('June 10, 2024 7:00PM EST'),
                    ),
                  ),
                  Card(
                    color: ThcColors.green,
                    margin: EdgeInsets.all(8.0), // Set margins for all sides
                    child: ListTile(
                      leading: FlutterLogo(size: 56.0),
                      title: Text('Upcoming Livestream C'),
                      subtitle: Text('June 15, 2024 12:00PM EST'),
                    ),
                  ),
                  Card(
                    color: ThcColors.green,
                    margin: EdgeInsets.all(8.0), // Set margins for all sides
                    child: ListTile(
                      leading: FlutterLogo(size: 56.0),
                      title: Text('Upcoming Livestream D'),
                      subtitle: Text('June 20, 2024 2:00PM EST'),
                    ),
                  ),
                  Card(
                    color: ThcColors.green,
                    margin: EdgeInsets.all(8.0), // Set margins for all sides
                    child: ListTile(
                      leading: FlutterLogo(size: 56.0),
                      title: Text('Upcoming Livestream E'),
                      subtitle: Text('June 25, 2024 4:00PM EST'),
                    ),
                  ),
                  // Add more ListTiles as needed
                ],
              ),
            ),
            // Add more headers and cards with ListViews as needed
          ],
        ),
      ),
    );
  }
}
