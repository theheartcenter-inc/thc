import 'package:flutter/material.dart';
import 'package:thc/models/navigation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationBar = NavBar.of(context);
    return Scaffold(
      bottomNavigationBar: navigationBar,
      body: navigationBar.page,
    );
  }
}
