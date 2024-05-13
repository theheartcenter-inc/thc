import 'dart:math';

import 'package:flutter/material.dart';
import 'package:thc/agora/livestream_button.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';

class CreateLivestream extends StatelessWidget {
  const CreateLivestream({super.key});

  DateTime get nextStream => DateTime.now();
  String get scheduledFor => 'Scheduled for: '
      '${nextStream.month}/${nextStream.day}/${nextStream.year} '
      '${nextStream.hour}:${nextStream.minute}';
  int get numberInLobby => Random().nextBool() ? 69 : 420;
  String get people => numberInLobby == 1 ? 'person' : 'people';

  @override
  Widget build(BuildContext context) {
    const semiBold = StyleText(weight: 600);
    return Center(
      child: Column(
        children: [
          const Spacer(flex: 20),
          Text(scheduledFor),
          const Spacer(flex: 2),
          const _GoLive(),
          const Spacer(flex: 2),
          Text('$numberInLobby $people waiting', style: semiBold),
          const Spacer(),
        ],
      ),
    );
  }
}

class _GoLive extends StatelessWidget {
  const _GoLive();

  @override
  Widget build(BuildContext context) {
    return const LivestreamButton(color: ThcColors.teal);
  }
}
