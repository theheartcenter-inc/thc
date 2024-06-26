import 'package:thc/firebase/firebase.dart';
import 'package:thc/utils/local_storage.dart';

enum UserType {
  participant,
  director,
  admin;

  factory UserType.fromJson(Json json) => values.byName((json['type'] as String).toLowerCase());

  static List<String> get testIds => [for (final userType in values) userType.testId];

  String get testId => 'test_$name';
  String get testName => 'First Lastname';

  ThcUser get testUser => switch (this) {
        participant => Participant(id: testId, name: testName),
        director => Director(id: testId, name: testName),
        admin => Admin(id: testId, name: testName),
      };

  Map<LocalStorage, dynamic> get testUserSaveData => {
        LocalStorage.loggedIn: true,
        LocalStorage.userId: testId,
        LocalStorage.password: testId,
        LocalStorage.userType: index,
        LocalStorage.firstLastName: testName,
      };

  @override
  String toString() => switch (this) {
        participant => 'Participant',
        director => 'Director',
        admin => 'Admin',
      };
}
