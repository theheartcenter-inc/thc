import 'dart:math';

import 'package:flutter/material.dart';
import 'package:thc/models/navigator.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/create_livestream/active_stream.dart';

class CreateLivestream extends StatefulWidget {
  const CreateLivestream({super.key});

  @override
  State<CreateLivestream> createState() => _CreateLivestreamState();
}

bool aboutToStart = false;

class _CreateLivestreamState extends State<CreateLivestream> {
  int peopleWaiting = Random().nextBool() ? 69 : 420;
  String get people => peopleWaiting == 1 ? 'person' : 'people';
  @override
  Widget build(BuildContext context) {
    final DateTime nextStream = DateTime.now();
    final niceFormat =
        '${nextStream.month}/${nextStream.day}/${nextStream.year} ${nextStream.hour}:${nextStream.minute}';
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
          Text('Scheduled for: $niceFormat'),
          const Spacer(flex: 2),
          FilledButton(
            onPressed: aboutToStart ? () => navigator.push(const ActiveStream()) : null,
            style: FilledButton.styleFrom(
              backgroundColor: ThcColors.teal,
              foregroundColor: ThcColors.darkBlue,
              shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.fromLTRB(30, 15, 30, 18),
            ),
            child: const Text('Go Live', style: TextStyle(fontSize: 36)),
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
