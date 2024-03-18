import 'package:flutter/material.dart';
import 'package:thc/models/local_storage.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/models/user.dart';
import 'package:thc/views/admin_portal/admin_portal.dart';
import 'package:thc/views/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => switch (userType) {
        UserType.participant => const ParticipantHomeScreen(),
        UserType.director => const DirectorHomeScreen(),
        UserType.admin => const AdminPortal(),
      };
}

class ParticipantHomeScreen extends StatefulWidget {
  const ParticipantHomeScreen({super.key});

  @override
  State<ParticipantHomeScreen> createState() => _ParticipantHomeScreenState();
}

class _ParticipantHomeScreenState extends State<ParticipantHomeScreen> {
  int _currentIndex = 0; //default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_currentIndex == 0 ? 'Home' : 'About Us'),
          actions: [
            IconButton(
              onPressed: () async {
                //await handle logout press
              },
              icon: const Icon(Icons.logout),
            )
          ],
          backgroundColor: _currentIndex == 0 ? const Color.fromARGB(255, 131, 124, 234) : const Color.fromARGB(199, 153, 205, 154),
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            //home page (index 0)
            Center(
              child: Text('Homepage Implementation'),
            ),
            //about us (index 1)
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

class DirectorHomeScreen extends StatelessWidget {
  const DirectorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FunPlaceholder('Home screen for directors!', color: context.colorScheme.secondary);
  }
}
