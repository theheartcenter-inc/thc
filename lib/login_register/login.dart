import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/login_register/forgot_password.dart';
import 'package:thc/login_register/register.dart';
import 'package:thc/login_register/verify_email.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/error_dialog.dart';

class BigButton extends StatelessWidget {
  const BigButton({
    required this.onPressed,
    this.style = const TextStyle(),
    required this.label,
    super.key,
  });

  final VoidCallback onPressed;
  final TextStyle style;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.cyan,
          foregroundColor: ThcColors.darkBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: Center(
            child: Text(
              label,
              style: style.merge(const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late bool _passwordVisible;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _passwordVisible = false;
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 50, 0, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Login', style: TextStyle(color: ThcColors.darkBlue, fontSize: 40)),
                Text('Welcome Back', style: TextStyle(color: ThcColors.darkBlue, fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(60),
                  topRight: Radius.circular(60),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: <Widget>[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: ThcColors.gray,
                            blurRadius: 10,
                            offset: Offset(0, 8),
                          )
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.grey)),
                            ),
                            child: TextField(
                              controller: _email,
                              autocorrect: false,
                              enableSuggestions: false,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                labelStyle: TextStyle(color: Colors.black),
                              ),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.grey)),
                            ),
                            child: TextField(
                              controller: _password,
                              obscureText: !_passwordVisible,
                              enableSuggestions: false,
                              autocorrect: false,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: const TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                  onPressed: () {
                                    setState(() => _passwordVisible = !_passwordVisible);
                                  },
                                ),
                              ),
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => navigator.noTransition(const ForgotPasswordScreen()),
                      child: const Text('Forgot Password?'),
                    ),
                    const SizedBox(height: 20),
                    BigButton(
                      onPressed: () async {
                        final email = _email.text;
                        final password = _password.text;
                        try {
                          await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          final user = FirebaseAuth.instance.currentUser;
                          final Map<String, Object> dataToSave = {
                            'name': 'random_name',
                            'uid': user!.uid,
                            'role': 'user',
                            'is_active': false,
                          };
                          FirebaseFirestore.instance
                              .collection('usersCollection')
                              .add(dataToSave);
                          if (user.emailVerified) {
                            navigator.pushReplacement(const HomeScreen());
                          } else {
                            user.sendEmailVerification();
                            navigator.pushReplacement(VerifyEmailScreen(user));
                          }
                        } on FirebaseAuthException catch (e) {
                          final errorMessage = switch (e.code) {
                            'invalid-credential' => 'Wrong credentials.',
                            'wrong-password' ||
                            'invalid-password' =>
                              'Invalid Password. Please enter password if blank.',
                            'invalid-email' => 'Invalid Email. Please enter email if blank.',
                            _ => 'Error: ${e.code}',
                          };
                          navigator.showDialog(ErrorDialog(errorMessage));
                        } catch (e) {
                          navigator.showDialog(ErrorDialog(e.toString()));
                        }
                      },
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      label: 'Login',
                    ),
                    TextButton(
                      onPressed: () => navigator.noTransition(
                        const RegisterScreen(),
                        replacing: true,
                      ),
                      child: const Text('Not registered yet? Register Here'),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
