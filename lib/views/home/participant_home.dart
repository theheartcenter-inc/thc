import 'package:flutter/material.dart';
import 'package:thc/models/theme.dart';

class ParticipantHomeScreen extends StatefulWidget {
  const ParticipantHomeScreen({super.key});

  @override
  State<ParticipantHomeScreen> createState() => _ParticipantHomeScreenState();
}

class _ParticipantHomeScreenState extends State<ParticipantHomeScreen> {
  int _currentIndex = 0; // default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Home' : 'About Us'),
        actions: [
          IconButton(
            onPressed: () async {
              // await handle logout press
            },
            icon: const Icon(Icons.logout),
          )
        ],
        backgroundColor: _currentIndex == 0 ? ThcColors.darkMagenta : ThcColors.green,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          // home page (index 0)
          Center(
            child: Text('Homepage Implementation'),
          ),
          // about us (index 1)
          Center(
            child: Text('About Us Implementation'),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
          BottomNavigationBarItem(label: 'About Us', icon: Icon(Icons.info)),
        ],
      ),
    );
  }
}
