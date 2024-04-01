import 'package:flutter/material.dart';
import 'package:thc/models/navigator.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/home/home_screen.dart';
import 'package:thc/views/login_register/forgot_password.dart';
import 'package:thc/views/login_register/register.dart';

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

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
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
                    TextButton(
                      onPressed: () => navigator.noTransition(const ForgotPasswordScreen()),
                      child: const Text('Forgot Password?'),
                    ),
                    const SizedBox(height: 20),
                    BigButton(
                      onPressed: () => navigator.pushReplacement(const HomeScreen()),
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
