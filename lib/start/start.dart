import 'package:flutter/material.dart';
import 'package:thc/start/za_hando.dart';
import 'package:thc/utils/bloc.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xff202428),
      body: ZaHando(),
    );
  }
}

enum LoginMethod {
  idName,
  noID,
  signIn;

  void call(LoginProgressTracker tracker, [bool? u]) => tracker.emit((this, u ?? false));
}

typedef LoginProgress = (LoginMethod, bool usernameEntered);

class LoginProgressTracker extends Cubit<LoginProgress> {
  LoginProgressTracker() : super((LoginMethod.idName, false));

  void noID([bool? u]) => LoginMethod.noID(this, u);
  void signIn([bool? u]) => LoginMethod.signIn(this, u);

  void usernameEntered() => emit((state.$1, true));
}
