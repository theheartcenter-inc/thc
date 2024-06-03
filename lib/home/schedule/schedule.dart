import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/home/schedule/src/all_scheduled_streams.dart';
import 'package:thc/home/schedule/src/schedule_editor.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/theme.dart';

class ScheduledStreamCard extends StatelessWidget {
  const ScheduledStreamCard({
    required Key super.key,
    required this.title,
    required this.timestamp,
    required this.active,
    required this.director,
  });

  ScheduledStreamCard.fromJson(Json json, {required Key super.key})
      : title = json['title'],
        timestamp = json['date'],
        active = json['active'],
        director = json['director'];

  final String title;
  final Timestamp timestamp;
  final bool active;
  final String director;

  @override
  Widget build(BuildContext context) {
    final String date = DateFormat('yyyy-MM-dd hh:mm a').format(timestamp.toDate());

    if (active) {
      return Card(
        color: ThcColors.green,
        margin: const EdgeInsets.all(8.0),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: () {
            context.read<NavBarSelection>().selectButton(NavBarButton.watchLive);
          },
          hoverColor: ThcColors.darkGreen.withOpacity(1 / 8),
          leading: const FlutterLogo(size: 56.0),
          title: Text(
            title,
            style: const StyleText(color: Colors.black),
          ),
          subtitle: Text(
            date,
            style: const StyleText(color: Colors.black),
          ),
        ),
      );
    } else {
      return Card(
        color: ThcColors.green,
        margin: const EdgeInsets.all(8.0),
        child: ListTile(
          leading: const FlutterLogo(size: 56.0),
          title: Text(
            title,
            style: const StyleText(color: Colors.black),
          ),
          subtitle: Text(
            date,
            style: const StyleText(color: Colors.black),
          ),
        ),
      );
    }
  }
}

class Schedule extends StatelessWidget {
  const Schedule({super.key});

  @override
  Widget build(BuildContext context) {
    final (:active, :scheduled) = ScheduledStreams.of(context);
    final ColorScheme colors = ThcColors.of(context);

    Widget? editButton;
    if (user.isAdmin) {
      editButton = IconButton.filled(
        icon: const Icon(Icons.edit),
        onPressed: () => navigator.push(const ScheduleEditor()),
      );
    }
    return Scaffold(
      body: Column(
        children: <Widget>[
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
          if (active.isEmpty) const Center(child: CircularProgressIndicator()),
          ...active,
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
          Expanded(
            child: scheduled.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView(children: scheduled),
          ),
        ],
      ),
      floatingActionButton: editButton,
    );
  }
}
