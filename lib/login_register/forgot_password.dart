import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thc/login_register/login.dart';
import 'package:thc/login_register/password_reset_sent.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/error_dialog.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _email;

  @override
  void initState() {
    _email = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

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
              style: StyleText(size: 40, color: ThcColors.darkBlue),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'We will send you a link to reset your password.',
              style: StyleText(size: 20, color: ThcColors.darkBlue),
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
                  child: TextField(
                    autocorrect: false,
                    enableSuggestions: false,
                    controller: _email,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      hintStyle: StyleText(color: Colors.grey),
                      border: InputBorder.none,
                      labelStyle: StyleText(color: Colors.black),
                    ),
                    style: const StyleText(color: Colors.black),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: BigButton(
                    onPressed: () async {
                      final email = _email.text;
                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

                        navigator.pushReplacement(const PasswordResetSentScreen());
                      } on FirebaseAuthException catch (e) {
                        final errorMessage = switch (e.code) {
                          'invalid-email' => 'Please enter a valid email.',
                          _ => 'Error: ${e.code}',
                        };
                        navigator.showDialog(ErrorDialog(errorMessage));
                      } catch (e) {
                        navigator.showDialog(ErrorDialog(e.toString()));
                      }
                    },
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
