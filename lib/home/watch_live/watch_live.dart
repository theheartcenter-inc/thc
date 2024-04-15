import 'dart:async';

import 'package:flutter/material.dart';
import 'package:thc/home/watch_live/watching_livestream.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/theme.dart';

class WatchLive extends StatelessWidget {
  const WatchLive({super.key});
  static final lightBackground = Color.lerp(ThcColors.pink, Colors.white, 0.33)!;
  static final darkBackground = Color.lerp(ThcColors.darkMagenta, Colors.black, 0.75)!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.lightDark(lightBackground, darkBackground),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // will eventually show current stream info
            const Text('This is the Stream Title', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => navigator.push(const LobbyScreen()),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThcColors.darkMagenta,
                foregroundColor: Colors.white,
              ),
              child: const Text('Join'),
            ),
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
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 5),
      () => mounted ? navigator.pushReplacement(const WatchingLivestream()) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Lobby')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "We've informed the host that you're here.\n"
                  'Please be patient and give them a few moments to let you join.',
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                onPressed: navigator.pop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Leave Lobby'),
              )
            ],
          ),
        ));
  }
}
