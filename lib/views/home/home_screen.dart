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

class ParticipantHomeScreen extends StatelessWidget {
  const ParticipantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          actions: [
            IconButton(onPressed: (){
              //handle logout press
            }, icon: const Icon(Icons.logout))
          ],
          backgroundColor: const Color.fromARGB(255, 131, 124, 234),
        ),
        body: const Center(child: Text("Implementation of body content")),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(label: "Home", icon: Icon(Icons.home)),
            BottomNavigationBarItem(label: "About Us", icon: Icon(Icons.info))
          ],
        ),
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
