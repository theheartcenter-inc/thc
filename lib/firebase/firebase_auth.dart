import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/firebase/firebase_setup.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/home/surveys/survey_questions.dart';
import 'package:thc/home/surveys/take_survey/survey.dart';
import 'package:thc/utils/app_config.dart';
import 'package:thc/utils/local_storage.dart';
import 'package:thc/utils/navigator.dart';

extension EmailSyntax on String {
  String get emailValidated {
    const zero = 48, nine = 57, a = 97, z = 122;
    const period = 46, underscore = 95;

    final s = toLowerCase();
    String newAndImproved = '';

    for (final (index, char) in characters.indexed) {
      newAndImproved += switch (s.codeUnitAt(index)) {
        >= zero && <= nine || >= a && <= z => char,
        period || underscore => char,
        _ when newAndImproved.endsWith('-') => '',
        _ => '-',
      };
    }

    return newAndImproved;
  }
}

String get _email {
  final String? id = LocalStorage.userId();
  if (id == null) return LocalStorage.email()!;
  final idEmail = 'userid_$id@theheartcenter.one';
  backendPrint('id: $id, authenticating as $idEmail');
  return idEmail;
}

Future<UserCredential> _fbSignIn() => FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _email,
      password: LocalStorage.password(),
    );
Future<UserCredential> _fbRegister() => FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _email,
      password: LocalStorage.password(),
    );

Future<String?> signIn() async {
  try {
    await _fbSignIn();
  } on FirebaseAuthException catch (e) {
    return switch (e.code) {
      'invalid-credential' => 'Wrong credentials.',
      'wrong-password' ||
      'invalid-password' =>
        'Invalid Password. Please enter password if blank.',
      'invalid-email' => 'Invalid Email. Please enter email if blank.',
      _ => 'Error: ${e.code}',
    };
  }
  if (LocalStorage.userId() case final id?) {
    if (useInternet) {
      user = await ThcUser.download(id);
    } else {
      loadUser();
    }
  } else if (useInternet) {
    user = await ThcUser.download(
      LocalStorage.email(),
      collection: Firestore.awaitingApproval,
    );
  }
  LocalStorage.loggedIn.save(true);
  LocalStorage.firstLastName.save(ThcUser.instance?.name);
  LocalStorage.userType.save(ThcUser.instance?.type?.index);
  navigator.pushReplacement(const HomeScreen());
  return null;
}

Future<String?> register() async {
  try {
    await _fbRegister();
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
    if (useInternet) {
      user = await ThcUser.download(id, collection: Firestore.unregistered);
      Firestore.unregistered.doc(id).delete();
      user.upload();
    } else {
      loadUser();
    }
  } else {
    final String name = LocalStorage.firstLastName();
    final String email = LocalStorage.email();
    user = ThcUser(name: name, email: email);
    Firestore.awaitingApproval.doc(email).set(user.json);
  }
  LocalStorage.loggedIn.save(true);
  LocalStorage.userType.save(ThcUser.instance?.type);
  navigator.pushReplacement(const HomeScreen());
  await Future.delayed(Durations.short2);
  navigator.push(SurveyScreen(questions: SurveyPresets.intro.questions));
  return null;
}

Future<String?> resetPassword() async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: LocalStorage.email()!);
    navigator.showSnackBar(
      const SnackBar(content: Text('check your email for a password reset link!')),
    );
    return null;
  } on FirebaseAuthException catch (e) {
    return switch (e.code) {
      'invalid-email' => 'Please enter a valid email.',
      _ => 'Error: ${e.code}',
    };
  }
}
