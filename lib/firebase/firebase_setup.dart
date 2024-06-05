import 'package:firebase_core/firebase_core.dart';
import 'package:thc/credentials/credentials.dart';
import 'package:thc/the_good_stuff.dart';

/// If there's an error here, check out the
/// [Private Credentials wiki page](https://github.com/theheartcenter-one/thc/wiki/Private-Credentials)
/// for a solution.
Future<void> initFirebase() async {
  final FirebaseOptions options = switch (defaultTargetPlatform) {
    TargetPlatform() when kIsWeb => FirebaseCredentials.web,
    TargetPlatform.android => FirebaseCredentials.android,
    TargetPlatform.iOS => FirebaseCredentials.ios,
    TargetPlatform.macOS => FirebaseCredentials.macos,
    TargetPlatform.linux || TargetPlatform.windows => FirebaseCredentials.web,
    TargetPlatform.fuchsia => throw Exception("(I don't think we'll be supporting Fuchsia)"),
  };

  await Firebase.initializeApp(options: options);
}

Future<void> loadUser() async {
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

  try {
    user = await ThcUser.download();
  } catch (e) {
    assert(false, e.toString());
    user = ThcUser(name: name, type: type, id: id, email: email);
  }
}
