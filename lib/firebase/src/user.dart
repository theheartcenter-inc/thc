import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/utils/app_config.dart';
import 'package:thc/utils/local_storage.dart';
import 'package:flutter/material.dart';

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
    bool? notify,
    String? profilePictureUrl,
    Widget? view,
    bool? isAudioEnabled,
    bool? isVideoEnabled,
  }) {
    assert((id ?? email) != null);

    return switch (type) {
      UserType.participant => Participant(
          name: name,
          id: id,
          email: email,
          registered: registered,
          notify: notify,
        ),
      UserType.director => Director(
          name: name,
          id: id,
          email: email,
          registered: registered,
          notify: notify,
          profilePictureUrl: profilePictureUrl,
          isAudioEnabled: isAudioEnabled,
          isVideoEnabled: isVideoEnabled,
          view: view,
        ),
      UserType.admin => Admin(
          name: name,
          id: id,
          email: email,
          registered: registered,
          notify: notify,
          profilePictureUrl: profilePictureUrl,
          isAudioEnabled: isAudioEnabled,
          isVideoEnabled: isVideoEnabled,
          view: view,
        ),
    };
  }

  /// {@macro ThcUser}
  ThcUser._({
    required this.name,
    required this.type,
    this.id,
    this.email,
    this.notify,
    this.registered = true,
    this.profilePictureUrl,
    this.isAudioEnabled,
    this.isVideoEnabled,
    this.view,
  }) : assert((id ?? email) != null);

  /// {@macro ThcUser}
  factory ThcUser.fromJson(Json json) {
    backendPrint('creating user from: $json');
    return ThcUser(
      name: json['name'],
      type: UserType.fromJson(json),
      id: json['id'],
      email: json['email'],
      notify: json['notify'],
      profilePictureUrl: json['profilePictureUrl'],
      isAudioEnabled: json['isAudioEnabled'],
      isVideoEnabled: json['isVideoEnabled'],
      view: json['view'],
    );
  }

  final String name;
  final UserType type;
  final String? id;
  final String? email;
  final bool registered;
  final bool? notify;
  final String? profilePictureUrl;
  bool? isAudioEnabled;
  bool? isVideoEnabled;
  final Widget? view;

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
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final File image = File(pickedFile.path);
        final String downloadUrl = await _uploadProfilePicture(id!, image);

        // Update the user's profile picture URL in Firestore
        await _collection.doc(firestoreId).update({'profilePictureUrl': downloadUrl});

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
    bool? isAudioEnabled,
    Widget? view,
    bool? isVideoEnabled,
    bool? registered,
    bool? notify,
  }) {
    return ThcUser(
      type: type ?? this.type,
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      notify: notify ?? this.notify,
      registered: registered ?? this.registered,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      view: view ?? this.view,
    );
  }

  String get firestoreId => id ?? email!;
  bool matches(String key) => key == id || key == email;

  Json get json => {
        'name': name,
        'notify': notify,
        'type': '$type',
        if (id != null) 'id': id,
        if (email != null) 'email': email,
        if (!registered) 'registered': false,
        if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
        if (isAudioEnabled != isAudioEnabled) 'isAudioEnabled': isAudioEnabled,
        if (isVideoEnabled != isVideoEnabled) 'isVideoEnabled': isVideoEnabled,
        if (view != view) 'view' : view,
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
        other.isAudioEnabled == isAudioEnabled &&
        other.isVideoEnabled == isVideoEnabled &&
        other.view == view &&
        other.registered == registered;
  }

  @override
  int get hashCode =>
      Object.hash(id, name, email, profilePictureUrl, registered, isAudioEnabled, isVideoEnabled, view);
}

class Participant extends ThcUser {
  Participant({
    required super.id,
    required super.name,
    super.email,
    super.registered = true,
    super.notify,
  }) : super._(type: UserType.participant, profilePictureUrl: null);
}

class Director extends ThcUser {
  Director({
    required super.id,
    required super.name,
    super.email,
    super.registered = true,
    super.notify,
    super.profilePictureUrl,
    super.isAudioEnabled,
    super.isVideoEnabled,
    super.view,
  }) : super._(type: UserType.director);
}

class Admin extends ThcUser {
  Admin({
    required super.id,
    required super.name,
    super.email,
    super.registered = true,
    super.notify,
    super.profilePictureUrl,
    super.isAudioEnabled,
    super.isVideoEnabled,
    super.view,
  }) : super._(type: UserType.admin);
}
