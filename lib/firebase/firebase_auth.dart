import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/home/surveys/survey_questions.dart';
import 'package:thc/home/surveys/take_survey/survey.dart';
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

String authId(String id) => 'userid_$id@theheartcenter.one';

Future<String?> register(String email, String password) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return null;
  } on FirebaseAuthException catch (e) {
    return switch (e.code) {
      'weak-password' =>
        'Google thinks this is a weak password.\nTry adding more special characters!',
      'email-already-in-use' => 'This email has already been registered.',
      'invalid-email' => 'Please enter a valid email address.',
      _ => 'Error: ${e.code}',
    };
  }
}

Future<String?> registerId(String userId, String password) async {
  if (await register(authId(userId), password) case final error?) return error;

  user = await ThcUser.download(userId, collection: Firestore.unregistered)
    ..upload();
  Firestore.unregistered.doc(userId).delete();

  LocalStorage.userId.save(userId);
  LocalStorage.password.save(password);
  LocalStorage.loggedIn.save(true);

  navigator
    ..pushReplacement(const HomeScreen())
    ..push(SurveyScreen(questions: SurveyPresets.intro.questions));
  return null;
}

Future<String?> registerEmail(String email, String password) async {
  if (await register(email, password) case final error?) return error;

  // TODO: verify email
  return null;
}
