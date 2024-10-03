import 'package:thc/home/schedule/src/all_scheduled_streams.dart';
import 'package:thc/home/schedule/src/schedule_editor.dart';
import 'package:thc/the_good_stuff.dart';

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
