import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:thc/credentials/credentials.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/utils/local_storage.dart';

/// If there's an error here, check out the
/// [Private Credentials wiki page](https://github.com/theheartcenter-one/thc/wiki/Private-Credentials)
/// for a solution.
Future<void> initFirebase() async {
  final options = switch (defaultTargetPlatform) {
    TargetPlatform() when kIsWeb => FirebaseCredentials.web,
    TargetPlatform.android => FirebaseCredentials.android,
    TargetPlatform.iOS => FirebaseCredentials.ios,
    TargetPlatform.macOS => FirebaseCredentials.macos,
    TargetPlatform.linux || TargetPlatform.windows => FirebaseCredentials.web,
    TargetPlatform.fuchsia => throw Exception("(I don't think we'll be supporting Fuchsia)"),
  };

  await Firebase.initializeApp(options: options);
}

void loadUser() {
  if (!LocalStorage.loggedIn()) return;

  final String name = LocalStorage.firstLastName();

  if (name.isEmpty) {
    assert(false, 'loggedIn is true, but the name is empty.');
    LocalStorage.firstLastName.save('First Lastname');
  }

  String? id = LocalStorage.userId();
  UserType? type = LocalStorage.userType();
  final String? email = LocalStorage.email();
  if (type == null) {
    assert(false, "Apparently we're logged in without a UserType.");
    type ??= UserType.participant;
  }
  if ((id ?? email) == null) {
    assert(false, "Apparently we're logged in without an email or user ID.");
    id ??= 'test_participant';
  }

  ThcUser.instance = ThcUser(name: name, type: type, id: id, email: email);

  if (id == null) return;

  try {
    ThcUser.download(id).then((user) => ThcUser.instance = user);
  } catch (e) {
    assert(false, e.toString());
  }
}
