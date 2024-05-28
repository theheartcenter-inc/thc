import 'src/user.dart';

export 'src/fetch_survey.dart';
export 'src/livestream.dart';
export 'src/user.dart';
export 'src/user_type.dart';
export 'src/firestore.dart';

ThcUser get user => ThcUser.instance!;
set user(ThcUser? updated) {
  ThcUser.instance = updated;
}

/// If the user has recently watched a livestream, this value will hold
/// the [ThcUser.firestoreId] of that stream's director.
String? directorId;
