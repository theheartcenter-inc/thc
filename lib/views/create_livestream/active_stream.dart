import 'dart:math';

import 'package:flutter/material.dart';
import 'package:thc/models/navigator.dart';

class ActiveStream extends StatelessWidget {
  const ActiveStream({super.key});

  @override
  Widget build(BuildContext context) {
    final int peopleWatching = Random().nextBool() ? 69 : 420;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Text(
                '$peopleWatching watching',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
          const Center(
            child: Text(
              'A very cool Agora stream will be here',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
      floatingActionButton: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
        ),
        onPressed: () => navigator.pop(),
        child: const Text(
          'End',
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
