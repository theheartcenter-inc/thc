import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/home/stream/active_stream.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/lerpy_hero.dart';

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
          const Spacer(),
          _StartSwitch((newVal) => context.read<LivestreamEnabled>().value = newVal),
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
    final enabled = context.watch<LivestreamEnabled>().value;
    return AnimatedOpacity(
      duration: Durations.long1,
      opacity: enabled ? 1 : 1 / 3,
      child: SizedBox(
        width: 175,
        height: 75,
        child: GoLive(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              overlayColor: const MaterialStatePropertyAll(Colors.black12),
              onTap: enabled
                  ? () async {
                      const duration = Durations.extralong1;
                      await Navigator.of(context).push(
                        PageRouteBuilder(
                          transitionDuration: duration,
                          reverseTransitionDuration: duration,
                          pageBuilder: (_, animation, __) => ChangeNotifierProvider(
                            create: (_) => StreamOverlayFadeIn(animation),
                            child: const ActiveStream(),
                          ),
                        ),
                      );
                      await Future.delayed(duration);
                      context.read<LivestreamEnabled>().value = false;
                    }
                  : null,
              child: Center(
                child: Text(
                  'Go Live',
                  style: StyleText(
                    weight: 600,
                    size: 32,
                    color: enabled ? Colors.black : ThcColors.gray,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension Cube on double {
  double get cubed => this * this * this;
}

class GoLive extends LerpyHero<ShapeDecoration> {
  const GoLive({super.key, super.child}) : super(tag: 'go live');

  @override
  ShapeDecoration lerp(
    ShapeDecoration a,
    ShapeDecoration b,
    double t,
    HeroFlightDirection direction,
  ) {
    final tLerp = switch (direction) {
      HeroFlightDirection.push => t.cubed,
      HeroFlightDirection.pop => 1 - (1 - t).cubed,
    };
    return ShapeDecoration.lerp(a, b, tLerp)!;
  }

  @override
  ShapeDecoration fromContext(BuildContext context) {
    final secondary = ThcColors.of(context).secondary;
    final lightness = HSLColor.fromColor(secondary).lightness;
    return ShapeDecoration(
      color: secondary,
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(lightness * 0x80),
      ),
    );
  }

  @override
  Widget builder(BuildContext context, ShapeDecoration value, Widget? child) {
    return Container(
      decoration: value,
      clipBehavior: Clip.antiAlias,
      child: child,
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
    final aboutToStart = context.watch<LivestreamEnabled>().value;
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

/// controls whether the "Go Live" button is enabled.
class LivestreamEnabled extends ValueNotifier<bool> {
  /// controls whether the "Go Live" button is enabled.
  LivestreamEnabled() : super(true);
}
