import 'dart:math';

import 'package:flutter/material.dart';
import 'package:thc/models/bloc.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/create_livestream/active_stream.dart';

class CreateLivestream extends StatefulWidget {
  const CreateLivestream({super.key});

  @override
  State<CreateLivestream> createState() => _CreateLivestreamState();
}

bool aboutToStart = true;

class _CreateLivestreamState extends State<CreateLivestream> {
  DateTime get nextStream => DateTime.now();
  String get scheduledFor => 'Scheduled for: '
      '${nextStream.month}/${nextStream.day}/${nextStream.year} '
      '${nextStream.hour}:${nextStream.minute}';
  int peopleWaiting = Random().nextBool() ? 69 : 420;
  String get people => peopleWaiting == 1 ? 'person' : 'people';

  void startStreaming() {
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: Durations.long4,
      pageBuilder: (_, animation, __) {
        return BlocProvider(
          create: (_) => StreamOverlayFadeIn(animation),
          child: const ActiveStream(),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 300,
            color: switch (context.colorScheme.brightness) {
              Brightness.light => Colors.white38,
              Brightness.dark => Colors.black38,
            },
            child: SwitchListTile.adaptive(
              title: const Text('stream about to start?'),
              value: aboutToStart,
              onChanged: (value) => setState(() => aboutToStart = value),
            ),
          ),
          const Spacer(flex: 20),
          Text(scheduledFor),
          const Spacer(flex: 2),
          Hero(
            tag: 'go live',
            child: FilledButton(
              onPressed: aboutToStart ? startStreaming : null,
              style: FilledButton.styleFrom(
                backgroundColor: ThcColors.teal,
                foregroundColor: Colors.black,
                shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.fromLTRB(30, 15, 30, 18),
              ),
              child: const Text('Go Live', style: TextStyle(fontSize: 36)),
            ),
          ),
          const Spacer(flex: 2),
          Text(
            '$peopleWaiting $people waiting',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
