import 'package:flutter/material.dart';

class ParticipantHomeScreen extends StatelessWidget {
  const ParticipantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              // handle logout press
            },
            icon: const Icon(Icons.logout),
          )
        ],
        backgroundColor: const Color.fromARGB(255, 131, 124, 234),
      ),
      body: const Center(child: Text('Implementation of body content')),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
          BottomNavigationBarItem(label: 'About Us', icon: Icon(Icons.info))
        ],
      ),
    );
  }
}
