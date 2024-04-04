import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thc/login_register/login.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/theme.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen(this.user, {super.key});
  final User? user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.black),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Verify Email',
                style: TextStyle(color: ThcColors.darkBlue, fontSize: 40),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(30),
              child: Center(
                child: Text(
                  "We've sent you an email verification. Please open it to verify your account.\n\n"
                  "If you haven't received your verification email yet, press the button below.",
                  style: TextStyle(color: ThcColors.darkBlue, fontSize: 20),
                ),
              ),
            ),
            BigButton(
              onPressed: () async {
                await user?.sendEmailVerification();
                navigator.showSnackBar(const SnackBar(content: Text('Email has been resent')));
              },
              label: 'Resend verification email',
            ),
            Center(
              child: TextButton(
                onPressed: () => navigator.noTransition(
                  const LoginScreen(),
                  replacing: true,
                ),
                child: const Text('Navigate to Log In'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
