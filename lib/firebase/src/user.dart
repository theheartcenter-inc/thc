import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/utils/app_config.dart';
import 'package:thc/utils/local_storage.dart';

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
    UserType? type,
    String? id,
    String? email,
  }) {
    assert((id ?? email) != null);

    return switch (type) {
      null => AwaitingApproval(
          name: name,
          email: email,
        ),
      UserType.participant => Participant(
          name: name,
          id: id,
          email: email,
        ),
      UserType.director => Director(
          name: name,
          id: id,
          email: email,
        ),
      UserType.admin => Admin(
          name: name,
          id: id,
          email: email,
        ),
    };
  }

  /// {@macro ThcUser}
  const ThcUser._({
    required this.name,
    this.type,
    this.id,
    this.email,
  }) : assert((id ?? email) != null);

  /// {@macro ThcUser}
  factory ThcUser.fromJson(Json json) {
    return ThcUser(
      name: json['name'],
      type: UserType.fromJson(json),
      id: json['id'],
      email: json['email'],
    );
  }

  final String name;
  final UserType? type;

  /// A unique string to identify the user, probably chosen by an admin.
  final String? id;

  /// Used for password recovery.
  final String? email;

  static ThcUser? instance;

  static Future<void> loadfromLocalStorage() async {
    if (!LocalStorage.loggedIn()) return;

    final String? id = LocalStorage.userId();
    if (useInternet && id != null) {
      // let's add a try/catch block here soon
      user = await download(id);
      return;
    }

    final String name = LocalStorage.firstLastName();
    assert(name.isNotEmpty);
    final UserType? type = LocalStorage.userType();
    final String? email = LocalStorage.email();

    user = ThcUser(name: name, type: type, id: id, email: email);
  }

  /// {@macro ThcUser}
  static Future<ThcUser> download(String id, {Firestore? collection}) async {
    if (!useInternet) {
      return UserType.values.firstWhere((value) => id.contains(value.name)).testUser;
    }

    final snapshot = await collection.doc(id).get();
    return ThcUser.fromJson(snapshot.data()!);
  }

  static Future<void> remove(String id, {Firestore? collection}) {
    return switch (useInternet && !UserType.testIds.contains(id)) {
      true => collection.doc(id).delete(),
      false => Future.delayed(const Duration(seconds: 3)),
    };
  }

  /// Saves the current user data to Firebase.
  Future<void> upload({Firestore? collection, bool saveLocally = true}) async {
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
        // need to delete both user ID & email authentication
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
    );
  }

  Json get json => {
        'name': name,
        'type': '$type',
        if (id != null) 'id': id,
        if (email != null) 'email': email,
      };

  bool get canLivestream => switch (type) {
        UserType.participant || null => false,
        UserType.director || UserType.admin => true,
      };

  bool get isAdmin => type == UserType.admin;

  @override
  bool operator ==(Object other) {
    return other is ThcUser &&
        other.runtimeType == runtimeType &&
        other.id == id &&
        other.name == name &&
        other.email == email;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, email);
}

class AwaitingApproval extends ThcUser {
  const AwaitingApproval({
    required super.name,
    super.email,
  }) : super._(type: null);
}

class Participant extends ThcUser {
  const Participant({
    required super.id,
    required super.name,
    super.email,
  }) : super._(type: UserType.participant);
}

class Director extends ThcUser {
  const Director({
    required super.id,
    required super.name,
    super.email,
  }) : super._(type: UserType.director);
}

class Admin extends ThcUser {
  const Admin({
    required super.id,
    required super.name,
    super.email,
  }) : super._(type: UserType.admin);
}
