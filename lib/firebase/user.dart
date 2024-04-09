import 'package:meta/meta.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/utils/app_config.dart';
import 'package:thc/utils/local_storage.dart';
import 'package:thc/utils/navigator.dart';

enum UserType {
  participant,
  director,
  admin;

  factory UserType.fromTestId(String id) =>
      values.firstWhere((userType) => id == userType.testUser.id);

  String get testId => 'test_$name';
  static const _testName = 'First LastName';

  ThcUser get testUser => switch (this) {
        participant => Participant(id: testId, name: _testName),
        director => Director(id: testId, name: _testName),
        admin => Admin(id: testId, name: _testName),
      };

  @override
  String toString() => switch (this) {
        participant => 'Participant',
        director => 'Director',
        admin => 'Admin',
      };
}

extension UserAuthorization on UserType? {
  bool get canLivestream => switch (this) {
        UserType.participant || null => false,
        UserType.director || UserType.admin => true,
      };

  bool get isAdmin => this == UserType.admin;
}

ThcUser? user;

UserType? get userType => user?.type;

String? get userId => StorageKeys.userId();

/// Currently not used in the login window, but this may change in the future.
void login(String id, String password) async {
  StorageKeys.userId.save(id);
  user = useInternet ? await ThcUser.download(id) : UserType.fromTestId(id).testUser;
  navigator.pushReplacement(const HomeScreen());
}

/// {@template ThcUser}
/// `User` is one of the Firebase classes, so we gotta use the name "THC user" 😏
/// {@endtemplate}
///
/// {@macro sealed_class}
@immutable
sealed class ThcUser {
  /// {@macro ThcUser}
  const ThcUser._({
    required this.type,
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
  });

  /// {@macro ThcUser}
  factory ThcUser({
    required UserType type,
    required String id,
    required String name,
    String? email,
    String? phoneNumber,
  }) {
    return switch (type) {
      UserType.participant => Participant(
          id: id,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
        ),
      UserType.director => Director(
          id: id,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
        ),
      UserType.admin => Admin(
          id: id,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
        ),
    };
  }

  /// {@macro ThcUser}
  factory ThcUser.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final email = json['email'];
    final phoneNumber = json['phone number'];

    return switch (
        UserType.values.byName(((json['type'] ?? 'participant') as String).toLowerCase())) {
      UserType.participant => Participant(
          id: id,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
        ),
      UserType.director => Director(
          id: id,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
        ),
      UserType.admin => Admin(
          id: id,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
        ),
    };
  }

  final UserType type;
  final String id;
  final String name;
  final String? email;
  final String? phoneNumber;

  /// {@macro ThcUser}
  static Future<ThcUser> download(String id) async {
    try {
      final snapshot = await db.doc('users/$id').get();
      return ThcUser.fromJson(snapshot.data()!);
    } catch (e) {
      print(e);
      throw Exception(e);
    }
  }

  ThcUser copyWith({
    UserType? type,
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
  }) {
    return ThcUser(
      type: type ?? this.type,
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Future<void> upload() async => db.doc('users/$id').set(json);
  Map<String, dynamic> get json => {
        'id': id,
        'type': '$type',
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phone number': phoneNumber,
      };

  @override
  bool operator ==(Object other) {
    return other is ThcUser &&
        other.runtimeType == runtimeType &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, email, phoneNumber);
}

class Participant extends ThcUser {
  const Participant({
    required super.id,
    required super.name,
    super.email,
    super.phoneNumber,
  }) : super._(type: UserType.participant);
}

class Director extends ThcUser {
  const Director({
    required super.id,
    required super.name,
    super.email,
    super.phoneNumber,
  }) : super._(type: UserType.director);
}

class Admin extends ThcUser {
  const Admin({
    required super.id,
    required super.name,
    super.email,
    super.phoneNumber,
  }) : super._(type: UserType.admin);
}
