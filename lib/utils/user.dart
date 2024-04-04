import 'package:thc/utils/local_storage.dart';

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

class Director {
  Director({
    required this.directorId,
    required this.name,
    required this.isLive,
  });

  factory Director.fromSnapshot(dynamic snapshot) {
    return Director(
      directorId: snapshot['director_id'],
      name: snapshot['name'],
      isLive: snapshot['is_live'] ?? false,
    );
  }

  final String directorId;
  final String name;
  final bool isLive;

  Map<String, dynamic> toDocument() => {
        'director_id': directorId,
        'name': name,
        'is_live': isLive,
      };
}

class Participant {
  Participant({
    required this.userId,
    required this.name,
    required this.lobby,
    required this.active,
    required this.directorId,
  });

  factory Participant.fromSnapshot(dynamic snapshot) {
    return Participant(
      userId: snapshot['user_id'],
      name: snapshot['name'],
      lobby: snapshot['lobby'],
      active: snapshot['active'] ?? false,
      directorId: snapshot['director_id'],
    );
  }

  final String userId;
  final String name;
  final String lobby;
  final bool active;
  final String directorId; // Foreign key

  Map<String, dynamic> toDocument() => {
        'user_id': userId,
        'name': name,
        'lobby': lobby,
        'active': active,
        'director_id': directorId,
      };
}
