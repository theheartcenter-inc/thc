import 'package:thc/models/local_storage.dart';

enum UserType {
  participant,
  director,
  admin;

  bool get canLivestream => switch (this) {
        participant => false,
        director || admin => true,
      };

  bool get isAdmin => this == admin;

  @override
  String toString() => switch (this) {
        participant => 'Participant',
        director => 'Director',
        admin => 'Admin',
      };
}

UserType get userType => StorageKeys.userType();
set userType(UserType type) {
  StorageKeys.userType.save(type.index);
}
