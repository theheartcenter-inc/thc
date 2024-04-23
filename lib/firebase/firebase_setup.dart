import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:thc/credentials/credentials.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/utils/app_config.dart';
import 'package:thc/utils/local_storage.dart';

/// If there's an error here, check out the
/// [Private Credentials wiki page](https://github.com/theheartcenter-one/thc/wiki/Private-Credentials)
/// for a solution.
Future<void> initFirebase() async {
  if (!useInternet) return;

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
  assert(name.isNotEmpty, 'loggedIn is true, but the name is empty.');

  final String? id = LocalStorage.userId();
  final UserType? type = LocalStorage.userType();
  final String? email = LocalStorage.email();
  assert(
    (id == null) == (type == null),
    "${id == null ? 'ID' : 'userType'} is null, but ${id != null ? 'ID' : 'userType'} isn't.",
  );
  assert(
    (id ?? email) != null,
    'loggedIn is true, but ID and email are both null.',
  );

  ThcUser.instance = ThcUser(name: name, type: type, id: id, email: email);
  if (useInternet && id != null) {
    // let's add a try/catch block here soon
    ThcUser.download(id).then((user) => ThcUser.instance = user);
  }
}
