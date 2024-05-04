import 'package:thc/firebase/src/user.dart';

export 'src/fetch_survey.dart';
export 'src/livestream.dart';
export 'src/user.dart';
export 'src/user_type.dart';
export 'src/firestore.dart';

ThcUser get user => ThcUser.instance!;
set user(ThcUser? updated) {
  ThcUser.instance = updated;
}

typedef Json = Map<String, dynamic>;
