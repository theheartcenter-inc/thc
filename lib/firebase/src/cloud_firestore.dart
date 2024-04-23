import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thc/firebase/firebase.dart';

enum Firestore {
  users,
  unregistered,
  awaitingApproval,
  surveys;

  @override
  String toString() => switch (this) {
        users || surveys => name,
        unregistered => 'users (not registered)',
        awaitingApproval => 'users (awaiting approval)',
      };
}

extension FetchFromFirebaseFirestore on Firestore? {
  CollectionReference<Json> get _this {
    final collection = '${this ?? Firestore.users}';
    return FirebaseFirestore.instance.collection(collection);
  }

  DocumentReference<Json> doc([String? path]) => _this.doc(path);

  Stream<QuerySnapshot<Json>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) {
    return _this.snapshots(includeMetadataChanges: includeMetadataChanges, source: source);
  }
}
