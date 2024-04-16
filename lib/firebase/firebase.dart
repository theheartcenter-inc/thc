import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:thc/credentials/credentials.dart';
import 'package:thc/utils/app_config.dart';

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

  final firebaseApp = await Firebase.initializeApp(options: options);
  db = FirebaseFirestore.instanceFor(
    app: firebaseApp,
    databaseId: firebaseApp.options.databaseURL,
  );

  // This is just a one-time setup: uncomment if there's a change to testUser or Firebase
  // for (final userType in UserType.values) {
  //   userType.testUser.upload();
  // }
}

late final FirebaseFirestore db;
