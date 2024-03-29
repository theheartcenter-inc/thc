import 'package:flutter/material.dart';
import 'package:thc/models/navigator.dart';
import 'package:thc/views/widgets.dart';

class WatchingLivestream extends StatefulWidget {
  const WatchingLivestream({super.key});

  @override
  State<WatchingLivestream> createState() => _WatchingLivestreamState();
}

class _WatchingLivestreamState extends State<WatchingLivestream> {
  @override
  Widget build(BuildContext context) {
    const placeholder = BottomNavigationBarItem(icon: SizedBox.shrink(), label: '');
    return Scaffold(
      backgroundColor: Colors.black,
      body: const FunPlaceholder('Watching a livestream!', color: Colors.grey),
      bottomNavigationBar: BottomNavigationBar(
        useLegacyColorScheme: false,
        backgroundColor: Colors.black,
        unselectedLabelStyle: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.w600,
        ),
        onTap: (_) => navigator.pop(),
        items: const [
          placeholder,
          placeholder,
          BottomNavigationBarItem(
            icon: Icon(Icons.logout, color: Colors.red, size: 24),
            label: 'leave',
          ),
        ],
      ),
    );
  }
}
