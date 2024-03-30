import 'package:flutter/material.dart';
import 'package:thc/models/navigator.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/login_register/login.dart';
import 'package:thc/views/login_register/password_reset_sent.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.black),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Forgot Password?',
              style: TextStyle(color: ThcColors.darkBlue, fontSize: 40),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'We will send you a link to reset your password.',
              style: TextStyle(
                color: ThcColors.darkBlue,
                fontSize: 20,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: BigButton(
                    onPressed: () => navigator.push(const PasswordResetSentScreen()),
                    label: 'Reset Password',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
