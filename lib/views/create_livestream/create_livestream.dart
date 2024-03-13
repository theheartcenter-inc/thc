import 'package:flutter/material.dart';
import 'package:thc/models/navigator.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/create_livestream/active_stream.dart';
import 'package:thc/views/widgets.dart';

class CreateLivestream extends StatefulWidget {
  const CreateLivestream({super.key});

  @override
  State<CreateLivestream> createState() => _CreateLivestreamState();
}

class _CreateLivestreamState extends State<CreateLivestream> {
  @override
  Widget build(BuildContext context) {
    final DateTime nextStream = DateTime.now();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Scheduled for: $nextStream'),
          ElevatedButton(
            onPressed: () => navigator.push(const ActiveStream()),
            child: const Text('Go Live'),
          )
        ],
      ),
    );
  }
}
