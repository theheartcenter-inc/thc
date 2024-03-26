//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thc/models/user.dart';
import 'package:thc/models/local_storage.dart';

class Director {
  final String directorId;
  final String name;
  final bool isLive;

  Director({
    required this.directorId,
    required this.name,
    required this.isLive,
  });

  factory Director.fromSnapshot(DocumentSnapshot snapshot) {
    return Director(
      directorId: snapshot['director_id'],
      name: snapshot['name'],
      isLive: snapshot['is_live'] ?? false,
    );
  }

  Map<String, dynamic> toDocument() => {
        'director_id': directorId,
        'name': name,
        'is_live': isLive,
      };
}

class User {
  final String userId;
  final String name;
  final String lobby;
  final bool active;
  final String directorId; // Foreign key

  User({
    required this.userId,
    required this.name,
    required this.lobby,
    required this.active,
    required this.directorId,
  });

  factory User.fromSnapshot(DocumentSnapshot snapshot) {
    return User(
      userId: snapshot['user_id'],
      name: snapshot['name'],
      lobby: snapshot['lobby'],
      active: snapshot['active'] ?? false,
      directorId: snapshot['director_id'],
    );
  }

  Map<String, dynamic> toDocument() => {
        'user_id': userId,
        'name': name,
        'lobby': lobby,
        'active': active,
        'director_id': directorId,
      };
}
