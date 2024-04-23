import 'package:thc/firebase/firebase.dart';

enum UserType {
  participant,
  director,
  admin;

  static UserType? fromJson(Json json) {
    final type = json['type'];
    for (final userType in values) {
      if (userType.toString() == type) return userType;
    }
    return null;
  }

  static List<String> get testIds => [for (final userType in values) userType.testId];

  String get testId => 'test_$name';
  String get testName => 'Test $name';

  ThcUser get testUser => switch (this) {
        participant => Participant(id: testId, name: testName),
        director => Director(id: testId, name: testName),
        admin => Admin(id: testId, name: testName),
      };

  @override
  String toString() => switch (this) {
        participant => 'Participant',
        director => 'Director',
        admin => 'Admin',
      };
}
