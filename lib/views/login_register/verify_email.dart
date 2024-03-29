import 'package:flutter/material.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Verify Email', style: TextStyle(color: Colors.white, fontSize: 40)),
              ],
            ),
          ),
        ],
      ),
      // Column(
      //   children: [
      //     const Text(
      //         "We've sent you an email verification. Please open it to verify your account"),
      //     const Text(
      //         "If you haven't received your verification email yet, press the button below"),
      //     TextButton(
      //       onPressed: () async {},
      //       child: const Text('Send email verification'),
      //     ),
      //   ],
      // ),
    );
  }
}
