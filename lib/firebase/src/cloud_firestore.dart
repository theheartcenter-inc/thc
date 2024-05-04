import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/utils/app_config.dart';

enum Firestore {
  users,
  unregistered,
  surveys;

  @override
  String toString() => switch (this) {
        users || surveys => name,
        unregistered => 'users (not registered)',
      };
}

typedef Snapshot = QuerySnapshot<Json>;

extension FetchFromFirebaseFirestore on Firestore? {
  CollectionReference<Json> get _this {
    final collection = '${this ?? Firestore.users}';
    backendPrint('collection: $collection');
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

extension GetData<T> on DocumentReference<T> {
  Future<T?> getData() async {
    T? data;
    try {
      final result = await get();
      backendPrint('result: $result');
      data = result.data();
    } catch (e) {
      backendPrint('got an error (type ${e.runtimeType})');
      if (superStrict) rethrow;
    }
    return data;
  }
}
