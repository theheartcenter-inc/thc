import 'package:flutter/material.dart';
import 'package:thc/models/bloc.dart';
import 'package:thc/views/create_livestream/active_stream.dart';
import 'package:thc/views/home/home_screen.dart';
import 'package:thc/views/login_register/forgot_password.dart';
import 'package:thc/views/login_register/register.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Login', style: TextStyle(color: Colors.white, fontSize: 40)),
                Text('Welcome Back', style: TextStyle(color: Colors.white, fontSize: 18)),
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
                            color: Color.fromRGBO(225, 95, 27, .3),
                            blurRadius: 20,
                            offset: Offset(0, 10),
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
                                  labelStyle: TextStyle(color: Colors.black)),
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
                      onPressed: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            transitionDuration: Durations.long2,
                            pageBuilder: (_, animation, __) => BlocProvider(
                              create: (_) => StreamOverlayFadeIn(animation),
                              child: const ForgotPasswordScreen(),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 50),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: const Color.fromRGBO(0, 188, 212, 1),
                      ),

                      // Add funtionality if user is director or admin will be linked to
                      // appropritate home screens
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
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
                                'Login',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            transitionDuration: Durations.long2,
                            pageBuilder: (_, animation, __) => BlocProvider(
                              create: (_) => StreamOverlayFadeIn(animation),
                              child: const RegisterScreen(),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Not registered yet? Register Here',
                      ),
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
