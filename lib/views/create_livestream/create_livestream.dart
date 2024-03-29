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

/// controls whether the "Go Live" button is enabled.
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
        pageBuilder: (_, animation, __) => BlocProvider(
          create: (_) => StreamOverlayFadeIn(animation),
          child: const ActiveStream(),
        ),
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
          _GoLive(onPressed: aboutToStart ? startStreaming : null),
          const Spacer(flex: 2),
          Text('$numberInLobby $people waiting', style: semiBold),
          const Spacer(),
        ],
      ),
    );
  }
}

/// When styling a button, you can use [FilledButton.styleFrom]
/// (other buttons have equivalent class methods, e.g. [OutlinedButton.styleFrom]),
/// or you can use the [ButtonStyle] class.
///
/// Using [ButtonStyle] usually involves creating a [MaterialPropertyResolver],
/// whereas the class method is a bit more simple.
final _buttonStyle = FilledButton.styleFrom(
  backgroundColor: ThcColors.teal,
  foregroundColor: Colors.black,
  shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30)),
  padding: const EdgeInsets.fromLTRB(30, 15, 30, 18),
);

class _GoLive extends StatelessWidget {
  const _GoLive({required this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'go live',
      child: FilledButton(
        onPressed: onPressed,
        style: _buttonStyle,
        child: const Text('Go Live', style: TextStyle(fontSize: 36)),
      ),
    );
  }
}

/// Toggles the value of [aboutToStart].
///
/// Flip this switch to simulate whether there's an upcoming stream.
class _StartSwitch extends StatelessWidget {
  const _StartSwitch(this.onChanged);
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: ColoredBox(
        color: context.lightDark(Colors.white38, Colors.black38),
        child: SwitchListTile.adaptive(
          activeTrackColor: ThcColors.teal,
          trackOutlineColor: MaterialStatePropertyAll(aboutToStart ? ThcColors.teal : null),
          title: const Text('stream about to start?'),
          value: aboutToStart,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
