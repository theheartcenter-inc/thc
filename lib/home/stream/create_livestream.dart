import 'dart:math' as math;

import 'package:thc/agora/livestream_button.dart';
import 'package:thc/the_good_stuff.dart';

class CreateLivestream extends StatelessWidget {
  const CreateLivestream({super.key});

  DateTime get nextStream => DateTime.now();
  String get scheduledFor => 'Scheduled for: '
      '${nextStream.month}/${nextStream.day}/${nextStream.year} '
      '${nextStream.hour}:${nextStream.minute}';
  int get numberInLobby => math.Random().nextBool() ? 69 : 420;
  String get people => numberInLobby == 1 ? 'person' : 'people';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Spacer(flex: 20),
          Text(scheduledFor),
          const Spacer(flex: 2),
          const LivestreamButton(color: ThcColors.teal),
          const Spacer(flex: 2),
          Text('$numberInLobby $people waiting', style: const TextStyle(weight: 600)),
          const Spacer(),
        ],
      ),
    );
  }
}
