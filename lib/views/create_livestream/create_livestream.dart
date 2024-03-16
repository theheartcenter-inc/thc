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
  int numberInLobby = Random().nextBool() ? 69 : 420;
  String get people => numberInLobby == 1 ? 'person' : 'people';

  void startStreaming() {
    setState(() => aboutToStart = false);
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: Durations.long2,
        pageBuilder: (_, animation, __) {
          return BlocProvider(
            create: (_) => StreamOverlayFadeIn(animation),
            child: const ActiveStream(),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const semiBold = TextStyle(fontWeight: FontWeight.w600);

    return Center(
      child: Column(
        children: [
          const Spacer(),
          _StartSwitch((value) => setState(() => aboutToStart = value)),
          const Spacer(flex: 20),
          Text(scheduledFor),
          const Spacer(flex: 2),
          _StartButton(onPressed: aboutToStart ? startStreaming : null),
          const Spacer(flex: 2),
          Text('$numberInLobby $people waiting', style: semiBold),
          const Spacer(),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = FilledButton.styleFrom(
      backgroundColor: ThcColors.teal,
      foregroundColor: Colors.black,
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.fromLTRB(30, 15, 30, 18),
    );

    return Hero(
      tag: 'go live',
      child: FilledButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: const Text('Go Live', style: TextStyle(fontSize: 36)),
      ),
    );
  }
}

class _StartSwitch extends StatelessWidget {
  const _StartSwitch(this.onChanged);
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      color: switch (context.colorScheme.brightness) {
        Brightness.light => Colors.white38,
        Brightness.dark => Colors.black38,
      },
      child: SwitchListTile.adaptive(
        activeTrackColor: ThcColors.teal,
        title: const Text('stream about to start?'),
        value: aboutToStart,
        onChanged: onChanged,
      ),
    );
  }
}
