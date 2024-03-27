import 'package:flutter/material.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/widgets.dart';

class WatchLive extends StatefulWidget {
  const WatchLive({super.key});

  @override
  State<WatchLive> createState() => _WatchLiveState();
}

class _WatchLiveState extends State<WatchLive> {

  //function to handle 'Join' press
  void navigateToLobby(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LobbyScreen())
    );
  }

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
                onPressed: navigateToLobby, 
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

//lobby screen
class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
    //function to handle 'Leave Lobby' press
  void leaveLobby(BuildContext context){
    Navigator.pop(context); //pop current screen
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
              onPressed: () => leaveLobby(context), //checks if user clicked 'Leave Lobby'
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

//this is the function to execute if host let participant join & participant didn't leave lobby
class ParticipantStreamScreen extends StatefulWidget {
  const ParticipantStreamScreen({super.key});

  @override
  State<ParticipantStreamScreen> createState() => _ParticipantStreamScreenState();
}

class _ParticipantStreamScreenState extends State<ParticipantStreamScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
            'This is the stream title (same with home page)'), // const for now
      ),
      body: const Center(
        // const for now
        child: Text('Implementation of host screen'),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
