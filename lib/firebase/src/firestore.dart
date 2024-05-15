import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thc/utils/app_config.dart';

enum Firestore {
  streams,
  surveys,
  scheduled_streams, // ignore: constant_identifier_names
  users;

  @override
  String toString() => name;

  CollectionReference<Json> get _collection {
    backendPrint('collection: $this');
    return FirebaseFirestore.instance.collection('$this');
  }

  DocumentReference<Json> doc([String? path]) => _collection.doc(path);

  Future<QuerySnapshot<Json>> get() => _collection.get();

  Stream<Snapshot> snapshots({
    ListenSource source = ListenSource.defaultSource,
    bool includeMetadataChanges = false,
  }) {
    return _collection.snapshots(
      source: source,
      includeMetadataChanges: includeMetadataChanges,
    );
  }
}

typedef Json = Map<String, dynamic>;
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
