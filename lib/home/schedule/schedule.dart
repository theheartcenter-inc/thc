import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/home/schedule/edit_schedule/schedule_editor.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';

class ScheduledStreamCard extends StatelessWidget {
  const ScheduledStreamCard({
    super.key,
    required this.title,
    required this.timestamp,
    required this.director,
    required this.active,
  });

  final String title;
  final Timestamp timestamp;
  final String director;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('yyyy-MM-dd hh:mm a');
    final DateTime date = DateTime.parse(timestamp.toDate().toString());
    final formatedDate = format.format(date);

    if (active) {
      return Card(
        color: ThcColors.green,
        margin: const EdgeInsets.all(8.0),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: () {
            context.read<NavBarIndex>().selectButton(NavBarButton.watchLive);
          },
          hoverColor: ThcColors.darkGreen.withOpacity(1 / 8),
          leading: const FlutterLogo(size: 56.0),
          title: Text(
            title,
            style: const StyleText(color: Colors.black),
          ),
          subtitle: Text(
            formatedDate,
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
            formatedDate,
            style: const StyleText(color: Colors.black),
          ),
        ),
      );
    }
  }
}

class Schedule extends StatefulWidget {
  const Schedule({super.key});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  Map<String, List<Widget>> scheduledStreams = {
    'active': [],
    'not_active': [],
  };

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    final QuerySnapshot snapshot = await Firestore.scheduled_streams.get();
    setState(() {
      for (final document in snapshot.docs) {
        if (document['active']) {
          scheduledStreams['active']!.add(ScheduledStreamCard(
            title: document['title'],
            timestamp: document['date'],
            director: document['director'],
            active: document['active'],
          ));
        } else {
          scheduledStreams['not_active']?.add(ScheduledStreamCard(
            title: document['title'],
            timestamp: document['date'],
            director: document['director'],
            active: document['active'],
          ));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = ThcColors.of(context);

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
        if (scheduledStreams['active']!.isEmpty) const Center(child: CircularProgressIndicator()),
        ...scheduledStreams['active']!,
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
        if (scheduledStreams['not_active']!.isEmpty) const Center(child: CircularProgressIndicator()),
        Expanded(child: ListView(children: scheduledStreams['not_active']!)),
      ],
    ),
    floatingActionButton: editButton,
    );
  }
}
