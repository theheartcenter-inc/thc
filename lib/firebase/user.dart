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

  factory UserType.fromJson(Json json) {
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

enum UserCollection { users, unregisteredUsers }

typedef Json = Map<String, dynamic>;

extension FetchFromFirebaseFirestore on UserCollection? {
  CollectionReference<Json> get _this {
    final collection = this ?? UserCollection.users;
    return db.collection(collection.name);
  }

  DocumentReference<Json> doc([String? path]) => _this.doc(path);

  Stream<QuerySnapshot<Json>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) {
    return _this.snapshots(includeMetadataChanges: includeMetadataChanges, source: source);
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

String? get userId => LocalStorage.userId();

/// {@template ThcUser}
/// We can't just call this class `User`, since that's one of the Firebase classes.
/// {@endtemplate}
///
/// {@macro sealed_class}
@immutable
sealed class ThcUser {
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
  const ThcUser._({
    required this.name,
    required this.type,
    this.id,
    this.email,
    this.phone,
  }) : assert((id ?? email ?? phone) != null);

  /// {@macro ThcUser}
  factory ThcUser.fromJson(Json json) {
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

  static Future<void> loadfromLocalStorage() async {
    final id = LocalStorage.userId();
    if (useInternet && id != null) {
      // let's add a try/catch block here soon
      user = await download(id);
      return;
    }

    final type = LocalStorage.userType();
    if (type == null) return;
    final email = LocalStorage.email();
    final name = LocalStorage.firstLastName();

    user = ThcUser(name: name, type: type, id: id, email: email);
  }

  /// {@macro ThcUser}
  static Future<ThcUser> download(String id, {UserCollection? collection}) async {
    if (!useInternet) {
      return UserType.values.firstWhere((value) => id.contains(value.name)).testUser;
    }

    final snapshot = await collection.doc(id).get();
    return ThcUser.fromJson(snapshot.data()!);
  }

  static Future<void> remove(String id, {UserCollection? collection}) {
    return switch (useInternet && !UserType._testIds.contains(id)) {
      true => collection.doc(id).delete(),
      false => Future.delayed(const Duration(seconds: 3)),
    };
  }

  /// Saves the current user data to Firebase.
  Future<void> upload({UserCollection? collection, bool saveLocally = true}) async {
    await collection.doc(id).set(json);
    if (!saveLocally) return;

    LocalStorage.email.save(email);
    LocalStorage.firstLastName.save(name);
  }

  /// Removes this user from the database.
  ///
  /// Any function that calls this method should also call `navigator.logout()`
  /// to return to the login screen.
  Future<void> yeet() => Future.wait([
        if (FirebaseAuth.instance.currentUser case final user?) user.delete(),
        if (id case final id?) remove(id),
      ]);

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

  Json get json => {
        'name': name,
        'type': '$type',
        if (id != null) 'id': id,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      };

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
