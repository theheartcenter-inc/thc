import 'package:flutter/material.dart';
import 'package:thc/models/theme.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(
          top: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: BackButton(
                color: ThcColors.darkBlue,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Verify Email', style: TextStyle(color: ThcColors.darkBlue, fontSize: 40)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Text(
                      "We've sent you an email verification. Please open it to verify your account.\n\nIf you haven't received your verification email yet, press the button below.",
                      style: TextStyle(
                        color: ThcColors.darkBlue,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: GestureDetector(
                onTap: () {
                  const snackBar = SnackBar(content: Text('Email has been resent'));

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 50),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.cyan,
                  ),
                  child: const Center(
                    child: Text(
                      'Resend verification email',
                      style: TextStyle(color: ThcColors.darkBlue),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
