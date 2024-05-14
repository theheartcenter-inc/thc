import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:thc/agora/active_stream.dart';
import 'package:thc/agora/livestream_button.dart';
import 'package:thc/home/watch_live/watching_livestream.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/placeholders.dart';

class WatchLive extends StatelessWidget {
  const WatchLive({super.key});

  @override
  Widget build(BuildContext context) {
    final bool active = math.Random().nextBool();
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Spacer(flex: 2),
            const Text('Daily Breathing Meditation', style: StyleText(size: 24)),
            const SizedBox(height: 10),
            const Text('Bob Long', style: StyleText(size: 18)),
            const Spacer(),
            const PlaceholderImage(width: 200),
            const Spacer(),
            Text(
              active ? 'active now!' : 'starting soon!',
              style: const StyleText(weight: 550),
            ),
            const SizedBox(height: 18),
            if (active)
              LivestreamButton(color: ThcColors.of(context).primary)
            else
              FilledButton(
                onPressed: () => navigator.push(const LobbyScreen()),
                child: const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text('Enter Lobby', style: StyleText(size: 18)),
                ),
              ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

/// If the director hasn't started the livestream yet,
/// participants are directed to this screen and can wait for it to start.
///
/// Will redirect to [WatchingLivestream] once the director is ready.
class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  /// Eventually, we'll connect with Firebase and Agora…
  /// for now, it's set up to show the [WatchingLivestream] after 5 seconds.
  late final Timer timer;
  @override
  void initState() {
    super.initState();
    timer = Timer(
      const Duration(seconds: 5),
      () => navigator.currentState.pushReplacement(ActiveStream.route),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Lobby')),
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      "We've informed the host that you're here.\n"
                      'Please be patient and give them a few moments to let you join.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(flex: 2),
                  ElevatedButton(
                    onPressed: navigator.pop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Leave Lobby'),
                  ),
                  const Spacer(),
                ],
              ),
              const LivestreamButton(color: Colors.transparent),
            ],
          ),
        ));
  }
}
