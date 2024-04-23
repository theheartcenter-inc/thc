import 'package:flutter/material.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';

class PasswordResetSentScreen extends StatelessWidget {
  const PasswordResetSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.black),
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Check your inbox',
                  style: StyleText(size: 40, color: ThcColors.darkBlue),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'If your email is associated with an account, '
                  'you will recived an email with a link to reset your password in your inbox.',
                  style: StyleText(size: 20, color: ThcColors.darkBlue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
