import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/utils/app_config.dart';

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
    UserType type = UserType.participant,
    String? id,
    String? email,
    bool registered = true,
  }) {
    assert((id ?? email) != null);

    return switch (type) {
      UserType.participant => Participant(
          name: name,
          id: id,
          email: email,
          registered: registered,
        ),
      UserType.director => Director(
          name: name,
          id: id,
          email: email,
          registered: registered,
        ),
      UserType.admin => Admin(
          name: name,
          id: id,
          email: email,
          registered: registered,
        ),
    };
  }

  /// {@macro ThcUser}
  const ThcUser._({
    required this.name,
    required this.type,
    this.id,
    this.email,
    this.registered = true,
  }) : assert((id ?? email) != null);

  /// {@macro ThcUser}
  factory ThcUser.fromJson(Json json) {
    backendPrint(json);
    return ThcUser(
      name: json['name'],
      type: UserType.fromJson(json),
      id: json['id'],
      email: json['email'],
    );
  }

  final String name;
  final UserType type;

  /// A unique string to identify the user, probably chosen by an admin.
  final String? id;

  /// Used for password recovery.
  final String? email;

  final bool registered;

  static ThcUser? instance;

  static const _collection = Firestore.users;

  /// {@macro ThcUser}
  static Future<ThcUser> download(String id) async {
    if (!useInternet) {
      return UserType.values.firstWhere((value) => id.contains(value.name)).testUser;
    }

    backendPrint('id: $id');
    final doc = _collection.doc(id);
    backendPrint('doc: $doc');
    final data = await doc.getData();
    if (data == null) throw Exception("snapshot of $_collection/$id doesn't exist");
    return ThcUser.fromJson(data);
  }

  /// Saves the current user data to Firebase.
  Future<void> upload({bool registering = false}) {
    return _collection.doc(firestoreId).set(json);
  }

  /// Removes this user from the database.
  ///
  /// Any function that calls this method should also call `navigator.logout()`
  /// to return to the login screen.
  Future<void> yeet() => Future.wait([
        // need to delete both user ID & email authentication
        if (FirebaseAuth.instance.currentUser case final user?) user.delete(),
        if (useInternet && !UserType.testIds.contains(id))
          _collection.doc(firestoreId).delete()
        else
          Future.delayed(const Duration(seconds: 3)),
      ]);

  /// {@macro ThcUser}
  ThcUser copyWith({
    UserType? type,
    String? id,
    String? name,
    String? email,
    String? phone,
    bool? registered,
  }) {
    return ThcUser(
      type: type ?? this.type,
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      registered: registered ?? this.registered,
    );
  }

  String get firestoreId => id ?? email!;
  bool matches(String key) => key == id || key == email;

  Json get json => {
        'name': name,
        'type': '$type',
        if (id != null) 'id': id,
        if (email != null) 'email': email,
      };

  bool get canLivestream => switch (type) {
        UserType.participant => false,
        UserType.director || UserType.admin => true,
      };

  bool get isAdmin => type == UserType.admin;

  @override
  bool operator ==(Object other) {
    return other is ThcUser &&
        other.runtimeType == runtimeType &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.registered == registered;
  }

  @override
  int get hashCode => Object.hash(id, name, email, registered);
}

class Participant extends ThcUser {
  const Participant({
    required super.id,
    required super.name,
    super.email,
    super.registered = true,
  }) : super._(type: UserType.participant);
}

class Director extends ThcUser {
  const Director({
    required super.id,
    required super.name,
    super.email,
    super.registered = true,
  }) : super._(type: UserType.director);
}

class Admin extends ThcUser {
  const Admin({
    required super.id,
    required super.name,
    super.email,
    super.registered = true,
  }) : super._(type: UserType.admin);
}
