import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/home/surveys/take_survey/survey.dart';
import 'package:thc/utils/app_config.dart';
import 'package:thc/utils/local_storage.dart';
import 'package:thc/utils/navigator.dart';

extension EmailSyntax on String {
  String get emailValidated {
    const zero = 48, nine = 57, a = 97, z = 122;
    const period = 46, underscore = 95;

    final String lowered = toLowerCase();
    String newAndImproved = '';

    for (final (index, char) in characters.indexed) {
      newAndImproved += switch (lowered.codeUnitAt(index)) {
        >= zero && <= nine || >= a && <= z => char,
        period || underscore => char,
        _ when newAndImproved.endsWith('-') => '',
        _ => '-',
      };
    }

    return newAndImproved;
  }
}

Future<UserCredential> authenticate({bool registering = false}) {
  final callback = registering
      ? FirebaseAuth.instance.createUserWithEmailAndPassword
      : FirebaseAuth.instance.signInWithEmailAndPassword;

  final String email = switch (LocalStorage.userId()) {
    final id? => 'userid_$id@theheartcenter.one',
    null => LocalStorage.email()!,
  };
  backendPrint('authenticating as "$email"');

  return callback(email: email, password: LocalStorage.password()!);
}

Future<String?> signIn() async {
  try {
    await authenticate();
  } on FirebaseException catch (e) {
    return switch (e.code) {
      'invalid-credential' => 'Wrong credentials.',
      'wrong-password' ||
      'invalid-password' =>
        'Invalid Password. Please enter password if blank.',
      'invalid-email' => 'Invalid Email. Please enter email if blank.',
      'unknown-error' => '',
      _ => '$e',
    };
  }
  if (LocalStorage.loggedIn()) return null;

  user = await ThcUser.download();

  LocalStorage.loggedIn.save(true);
  LocalStorage.firstLastName.save(ThcUser.instance?.name);
  LocalStorage.userType.save(ThcUser.instance?.type.index);
  navigator.pushReplacement(const HomeScreen());
  return null;
}

Future<String?> register() async {
  try {
    await authenticate(registering: true);
  } on FirebaseAuthException catch (e) {
    return switch (e.code) {
      'weak-password' =>
        'Google thinks this is a weak password.\nTry adding more special characters!',
      'email-already-in-use' => 'This email has already been registered.',
      'invalid-email' => 'Please enter a valid email address.',
      _ => 'Error: ${e.code}',
    };
  }
  if (LocalStorage.userId() case final id?) {
    user = await ThcUser.download(id);
    user = user.copyWith(registered: true);
    user.upload();
  } else {
    final String name = LocalStorage.firstLastName();
    final String email = LocalStorage.email();
    user = ThcUser(name: name, email: email);
    Firestore.users.doc(email).set(user.json);
  }
  LocalStorage.loggedIn.save(true);
  LocalStorage.userType.save(ThcUser.instance?.type.index);
  final introQuestions = await ThcSurvey.introSurvey.getQuestions();
  navigator.pushReplacement(const HomeScreen());
  await Future.delayed(Durations.short2);
  navigator.push(SurveyScreen(introQuestions, surveyType: ThcSurvey.introSurvey));
  return null;
}

Future<String?> resetPassword() async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: LocalStorage.email()!);
    navigator.snackbarMessage('check your email for a password reset link!');
    return null;
  } on FirebaseAuthException catch (e) {
    return switch (e.code) {
      'invalid-email' => 'Please enter a valid email.',
      _ => 'Error: ${e.code}',
    };
  }
}
