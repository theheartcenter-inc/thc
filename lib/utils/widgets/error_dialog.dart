import 'package:flutter/material.dart';
import 'package:thc/utils/navigator.dart';

class ErrorDialog extends StatelessWidget {
  const ErrorDialog(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('An error occurred'),
      content: Text(text),
      actions: [
        TextButton(onPressed: () => navigator.pop(), child: const Text('okay')),
      ],
    );
  }
}
