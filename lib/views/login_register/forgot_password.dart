import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thc/models/navigator.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/utils/show_error_dialog.dart';
import 'package:thc/views/login_register/login.dart';
import 'package:thc/views/login_register/password_reset_sent.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
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
                  child: TextField(
                    autocorrect: false,
                    enableSuggestions: false,
                    controller: _email,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: BigButton(
                    onPressed: () async {
                      final email = _email.text;
                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                        
                        navigator.pushReplacement(
                          const PasswordResetSentScreen(),
                        );
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'invalid-email') {
                          await showErrorDialog(
                            context,
                            'Please Enter a valid email.',
                          );
                        } else {
                          await showErrorDialog(
                            context,
                            'Error: ${e.code}',
                          );
                        }
                      } catch (e) {
                        await showErrorDialog(
                          context,
                          e.toString(),
                        );
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
