import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thc/login_register/login.dart';
import 'package:thc/login_register/verify_email.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/error_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
            child: Text(
              'Register',
              style: TextStyle(color: ThcColors.darkBlue, fontSize: 40),
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
                          ),
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
                              autocorrect: false,
                              enableSuggestions: false,
                              controller: _email,
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
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
                    BigButton(
                      onPressed: () async {
                        final email = _email.text;
                        final password = _password.text;
                        var user = FirebaseAuth.instance.currentUser;
                        try {
                          await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                          user = FirebaseAuth.instance.currentUser;
                          await user?.sendEmailVerification();
                          navigator.pushReplacement(VerifyEmailScreen(user));
                        } on FirebaseAuthException catch (e) {
                          final errorMessage = switch (e.code) {
                            'weak-password' => 'Weak password',
                            'email-already-in-use' => 'Email is already in use',
                            'invalid-email' => 'Invalid email entered',
                            _ => 'Error: ${e.code}',
                          };
                          navigator.showDialog(builder: (_) => ErrorDialog(errorMessage));
                          user?.delete();
                        } catch (e) {
                          navigator.showDialog(builder: (_) => ErrorDialog(e.toString()));
                        }
                      },
                      label: 'Register',
                    ),
                    TextButton(
                      onPressed: () => navigator.noTransition(
                        const LoginScreen(),
                        replacing: true,
                      ),
                      child: const Text('All ready registered? Login Here'),
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
