import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/home/schedule/src/all_scheduled_streams.dart';
import 'package:thc/home/schedule/src/schedule_editor.dart';
import 'package:thc/the_good_stuff.dart';

class ScheduledStreamCard extends StatelessWidget {
  const ScheduledStreamCard({
    required FirestoreID id,
    required this.title,
    required this.timestamp,
    required this.active,
    required this.director,
  }) : super(key: id);

  ScheduledStreamCard.fromJson(Json json, FirestoreID id)
      : this(
          id: id,
          title: json['title'] ?? '[title not found]',
          timestamp: json['timestamp'] ?? Timestamp.now(),
          active: json['active'] ?? false,
          director: json['director'] ?? '[director not found]',
        );

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
            style: const TextStyle(color: Colors.black),
          ),
          subtitle: Text(
            date,
            style: const TextStyle(color: Colors.black),
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
            style: const TextStyle(color: Colors.black),
          ),
          subtitle: Text(
            date,
            style: const TextStyle(color: Colors.black),
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
              style: TextStyle(
                size: 24.0,
                color: colors.inverseSurface,
                weight: 700,
              ),
            ),
          ),
          if (active.isEmpty) const Center(child: CircularProgressIndicator()),
          ...active,
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Upcoming Livestreams',
              style: TextStyle(
                size: 24.0,
                color: colors.inverseSurface,
                weight: 700,
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
