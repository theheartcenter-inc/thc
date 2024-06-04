import 'package:flutter/material.dart';
import 'package:thc/utils/navigator.dart';

class InfoDialog extends StatelessWidget {
  const InfoDialog({super.key, required this.titleText, required this.bodyText});

  final String titleText;
  final String bodyText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titleText),
      content: Text(bodyText),
      actions: [TextButton(onPressed: navigator.pop, child: const Text('OK'))],
    );
  }
}

class ErrorDialog extends InfoDialog {
  const ErrorDialog(String text, {super.key})
      : super(titleText: 'An error occurred', bodyText: text);
}
