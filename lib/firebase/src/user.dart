import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/utils/app_config.dart';
import 'package:thc/utils/local_storage.dart';

@immutable
sealed class ThcUser {
  /// {@macro ThcUser}
  factory ThcUser({
    required String name,
    UserType type = UserType.participant,
    String? id,
    String? email,
    bool registered = true,
    String? profilePictureUrl,
  }) {
    assert((id ?? email) != null);

    return switch (type) {
      UserType.participant => Participant(
          name: name,
          id: id,
          email: email,
          registered: registered,
          profilePictureUrl: profilePictureUrl,
        ),
      UserType.director => Director(
          name: name,
          id: id,
          email: email,
          registered: registered,
          profilePictureUrl: profilePictureUrl,
        ),
      UserType.admin => Admin(
          name: name,
          id: id,
          email: email,
          registered: registered,
          profilePictureUrl: profilePictureUrl,
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
    this.profilePictureUrl,
  }) : assert((id ?? email) != null);

  /// {@macro ThcUser}
  factory ThcUser.fromJson(Json json) {
    backendPrint('creating user from: $json');
    return ThcUser(
      name: json['name'],
      type: UserType.fromJson(json),
      id: json['id'],
      email: json['email'],
      profilePictureUrl: json['profilePictureUrl'],
    );
  }

  final String name;
  final UserType type;
  final String? id;
  final String? email;
  final bool registered;
  final String? profilePictureUrl;

  static const _collection = Firestore.users;
  static ThcUser? instance;

  /// {@macro ThcUser}
  static Future<ThcUser> download([String? id]) async {
    id ??= LocalStorage.userId() ?? LocalStorage.email()!;
    backendPrint('id: $id');
    final DocumentReference<Json> doc = _collection.doc(id);
    backendPrint('doc: $doc');
    final Json? data = await doc.getData();
    if (data == null) throw Exception("snapshot of $_collection/$id doesn't exist");
    return ThcUser.fromJson(data);
  }

  /// Saves the current user data to Firebase.
  Future<void> upload() => _collection.doc(firestoreId).set(json);

  /// Removes this user from the database.
  ///
  /// Any function that calls this method should also call `navigator.logout()`
  /// to return to the login screen.
  Future<void> yeet() => Future.wait([
        if (FirebaseAuth.instance.currentUser case final user?) user.delete(),
        if (UserType.testIds.contains(id))
          Future.delayed(const Duration(seconds: 3))
        else
          _collection.doc(firestoreId).delete(),
      ]);

  /// Update the profile picture URL for the user.
  Future<void> updateProfilePicture() async {
    if (type == UserType.director || type == UserType.admin) {
      final ImagePicker picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File image = File(pickedFile.path);
        String downloadUrl = await _uploadProfilePicture(id!, image);

        // Update the user's profile picture URL in Firestore
        await _collection.doc(firestoreId).update({
          'profilePictureUrl': downloadUrl,
        });

        // Update local profilePictureUrl
        copyWith(profilePictureUrl: downloadUrl);
      }
    } else {
      throw Exception('Only admins and directors can update profile pictures.');
    }
  }

  Future<String> _uploadProfilePicture(String userId, File image) async {
    final storageRef = FirebaseStorage.instance.ref();
    final profilePicRef = storageRef.child('profile_pics/$userId.jpg');

    await profilePicRef.putFile(image);

    return await profilePicRef.getDownloadURL();
  }

  /// {@macro ThcUser}
  ThcUser copyWith({
    UserType? type,
    String? id,
    String? name,
    String? email,
    String? profilePictureUrl,
    bool? registered,
  }) {
    return ThcUser(
      type: type ?? this.type,
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      registered: registered ?? this.registered,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }

  String get firestoreId => id ?? email!;
  bool matches(String key) => key == id || key == email;

  Json get json => {
        'name': name,
        'type': '$type',
        if (id != null) 'id': id,
        if (email != null) 'email': email,
        if (!registered) 'registered': false,
        if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
      };

  bool get canLivestream => switch (type) {
        UserType.participant => false,
        UserType.director || UserType.admin => true,
      };

  bool get isAdmin => type == UserType.admin;

  CollectionReference<Json> get streamData => _collection.doc(firestoreId).collection('streams');

  @override
  bool operator ==(Object other) {
    return other is ThcUser &&
        other.runtimeType == runtimeType &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.profilePictureUrl == profilePictureUrl &&
        other.registered == registered;
  }

  @override
  int get hashCode => Object.hash(id, name, email, profilePictureUrl, registered);
}

class Participant extends ThcUser {
  const Participant({
    required super.id,
    required super.name,
    super.email,
    super.registered = true,
    super.profilePictureUrl,
  }) : super._(type: UserType.participant);
}

class Director extends ThcUser {
  const Director({
    required super.id,
    required super.name,
    super.email,
    super.registered = true,
    super.profilePictureUrl,
  }) : super._(type: UserType.director);
}

class Admin extends ThcUser {
  const Admin({
    required super.id,
    required super.name,
    super.email,
    super.registered = true,
    super.profilePictureUrl,
  }) : super._(type: UserType.admin);
}
