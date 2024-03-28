import 'dart:async';

import 'package:flutter/material.dart';
import 'package:thc/models/navigation.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/widgets.dart';

class WatchLive extends StatelessWidget {
  const WatchLive({super.key});
  static final darkBackground = Color.lerp(ThcColors.darkMagenta, Colors.black, 0.75)!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.lightDark(ThcColors.pink, darkBackground),
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
/// Will redirect to [ParticipantStreamScreen] once the director is ready.
class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  /// Eventually, we'll connect with Firebase and Agora…
  /// for now, it's set up to show the [ParticipantStreamScreen] after 5 seconds.
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 5),
      () => navigator.pushReplacement(const ParticipantStreamScreen()),
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
                onPressed: () => navigator.pop(),
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

/// this is the function to execute if host let participant join & participant didn't leave lobby
class ParticipantStreamScreen extends StatefulWidget {
  const ParticipantStreamScreen({super.key});

  @override
  State<ParticipantStreamScreen> createState() => _ParticipantStreamScreenState();
}

class _ParticipantStreamScreenState extends State<ParticipantStreamScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: const FunPlaceholder(
        'Watching a livestream!',
        color: Colors.grey,
        buildScaffold: false,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        onTap: (_) => navigator.pop(),
        items: const [
          // I am dummy item 1
          BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''),
          // I am dummy item 2
          BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout, color: Colors.red, size: 24),
            label: 'Leave', // Add label for clarity
          ),
        ],
      ),
    );
  }
}
