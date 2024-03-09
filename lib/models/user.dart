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
