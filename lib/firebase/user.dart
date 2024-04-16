import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/utils/app_config.dart';
import 'package:thc/utils/local_storage.dart';

enum UserType {
  participant,
  director,
  admin;

  factory UserType.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    return values.firstWhere((userType) => userType.toString() == type);
  }

  static List<String> get _testIds => [for (final userType in values) userType.testId];

  String get testId => 'test_$name';
  static const _testName = 'First Lastname';

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

// ignore: constant_identifier_names
enum UserCollection { users, unregistered_users }

extension GetCollection on UserCollection? {
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    final userCollection = this ?? UserCollection.users;
    final dbCollection = db.collection(userCollection.name);

    return dbCollection.doc(path);
  }
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

/// {@template ThcUser}
/// We can't just call this class `User`, since that's one of the Firebase classes.
/// {@endtemplate}
///
/// {@macro sealed_class}
@immutable
sealed class ThcUser {
  /// {@macro ThcUser}
  const ThcUser._({
    required this.name,
    required this.type,
    this.id,
    this.email,
    this.phone,
  }) : assert((id ?? email ?? phone) != null);

  /// {@macro ThcUser}
  factory ThcUser({
    required String name,
    required UserType type,
    String? id,
    String? email,
    String? phone,
  }) {
    return switch (type) {
      UserType.participant => Participant(
          name: name,
          id: id,
          email: email,
          phone: phone,
        ),
      UserType.director => Director(
          name: name,
          id: id,
          email: email,
          phone: phone,
        ),
      UserType.admin => Admin(
          name: name,
          id: id,
          email: email,
          phone: phone,
        ),
    };
  }

  /// {@macro ThcUser}
  factory ThcUser.fromJson(Map<String, dynamic> json) {
    return ThcUser(
      name: json['name'],
      type: UserType.fromJson(json),
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  final String name;
  final UserType type;

  /// A unique string to identify the user, probably chosen by an admin.
  final String? id;

  /// Used for password recovery.
  final String? email, phone;

  /// {@macro ThcUser}
  static Future<ThcUser> download(String id, {UserCollection? userCollection}) async {
    if (!useInternet) {
      return UserType.values.firstWhere((value) => id.contains(value.name)).testUser;
    }

    final snapshot = await userCollection.doc(id).get();
    return ThcUser.fromJson(snapshot.data()!);
  }

  static Future<void> remove(String id, {UserCollection? userCollection}) async {
    late final isTestUser = UserType._testIds.contains(id);
    if (useInternet && !isTestUser) await userCollection.doc(id).delete();
  }

  /// {@macro ThcUser}
  ThcUser copyWith({
    UserType? type,
    String? id,
    String? name,
    String? email,
    String? phone,
  }) {
    return ThcUser(
      type: type ?? this.type,
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
    );
  }

  Map<String, dynamic> get json => {
        'name': name,
        'type': '$type',
        if (id != null) 'id': id,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      };

  /// Saves the current user data to Firebase.
  Future<void> upload({UserCollection? userCollection}) => userCollection.doc(id).set(json);

  /// Removes this user from the database.
  ///
  /// Any function that calls this method should also call `navigator.logout()`
  /// to return to the login screen.
  Future<void> yeet() => Future.wait([
        if (FirebaseAuth.instance.currentUser case final user?) user.delete(),
        if (id case final id?) remove(id),
      ]);

  @override
  bool operator ==(Object other) {
    return other is ThcUser &&
        other.runtimeType == runtimeType &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.phone == phone;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, email, phone);
}

class Participant extends ThcUser {
  const Participant({
    required super.id,
    required super.name,
    super.email,
    super.phone,
  }) : super._(type: UserType.participant);
}

class Director extends ThcUser {
  const Director({
    required super.id,
    required super.name,
    super.email,
    super.phone,
  }) : super._(type: UserType.director);
}

class Admin extends ThcUser {
  const Admin({
    required super.id,
    required super.name,
    super.email,
    super.phone,
  }) : super._(type: UserType.admin);
}
