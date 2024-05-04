import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/utils/app_config.dart';

enum Firestore {
  streams,
  surveys,
  users;

  @override
  String toString() => name;

  CollectionReference<Json> get _collection {
    backendPrint('collection: $this');
    return FirebaseFirestore.instance.collection('$this');
  }

  DocumentReference<Json> doc([String? path]) => _collection.doc(path);

  Stream<QuerySnapshot<Json>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) {
    return _collection.snapshots(includeMetadataChanges: includeMetadataChanges, source: source);
  }
}

typedef Snapshot = QuerySnapshot<Json>;

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
