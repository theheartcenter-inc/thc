import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:thc/credentials/credentials.dart';

Future<FirebaseApp> initFirebase() {
  final options = switch (defaultTargetPlatform) {
    TargetPlatform() when kIsWeb => FirebaseCredentials.web,
    TargetPlatform.android => FirebaseCredentials.android,
    TargetPlatform.iOS => FirebaseCredentials.ios,
    TargetPlatform.macOS => FirebaseCredentials.macos,
    TargetPlatform.linux || TargetPlatform.windows => FirebaseCredentials.web,
    TargetPlatform.fuchsia => throw Exception("(I don't think we'll be supporting Fuchsia)"),
  };

  return Firebase.initializeApp(options: options);
}
