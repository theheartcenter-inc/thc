import 'dart:async';

import 'package:flutter/material.dart';
import 'package:thc/models/navigation.dart';
import 'package:thc/models/theme.dart';

class WatchLive extends StatefulWidget {
  const WatchLive({super.key});

  @override
  State<WatchLive> createState() => _WatchLiveState();
}

class _WatchLiveState extends State<WatchLive> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: ThcColors.pink,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text( //const for now
                'This is the Stream Title', //stream title should be updated based on what stream is currently avaliable
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              ElevatedButton( //change btn color
                onPressed: () => navigator.push(const LobbyScreen()), 
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThcColors.darkMagenta,
                ),
                child: const Text(
                  'Join',
                  style: TextStyle(color: Colors.white),
                  ),
                )
            ],
          )
        )
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
  /// Eventually, we'll connect with Firebase and Agora—
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
      appBar: AppBar(
        title: const Text(
          'Lobby',
          style: TextStyle(color: Colors.white),
          ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("We've informed the host that you're here. Please be patient and give them a few moments to let you join."),
            const SizedBox(height:20),
            ElevatedButton(
              onPressed: () => navigator.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Leave Lobby',
                style: TextStyle(color: Colors.white),
                ),
            )
          ],
        ),
      )
    );
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
      body: const Center(
        // const for now
        child: Text('Implementation of host screen'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (_) => navigator.pop(),
        items: const [
          BottomNavigationBarItem(
            // I am dummy item 1
            icon: SizedBox.shrink(),
            label: '',
          ),
          BottomNavigationBarItem(
            // I am dummy item 2
            icon: SizedBox.shrink(),
            label: '',
          ),
          BottomNavigationBarItem(
            
            icon: Icon(
              Icons.logout,
              color: Colors.red,
              size: 24,
            ),
            label: 'Leave', // Add label for clarity
          ),
        ],
      ),
    );
  }
}
