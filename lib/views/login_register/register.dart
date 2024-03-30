import 'package:flutter/material.dart';
import 'package:thc/models/navigator.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/login_register/login.dart';
import 'package:thc/views/login_register/verify_email.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
                            child: const TextField(
                              decoration: InputDecoration(
                                hintText: 'Email',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.grey)),
                            ),
                            child: const TextField(
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    BigButton(
                      onPressed: () => navigator.push(const VerifyEmailScreen()),
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
