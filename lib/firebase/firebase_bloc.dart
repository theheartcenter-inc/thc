import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thc/the_good_stuff.dart';

typedef SnapshotDoc = DocumentSnapshot<Json>;
typedef SnapshotDocs = List<SnapshotDoc>;
typedef SnapshotBuilder = Stream<QuerySnapshot<Json>> Function();
typedef SnapshotChanged<T> = void Function(T current, SnapshotDoc doc);

const _alwaysRunIsolate = false;

abstract class FirebaseBloc<T> extends Bloc {
  FirebaseBloc(
    SnapshotBuilder snapshotBuilder, {
    required this.data,
    required SnapshotChanged<T> onData,
  }) {
    _streamSubscription = snapshotBuilder().listen((snapshot) async {
      final SnapshotDocs docs = [for (final change in snapshot.docChanges) change.doc];
      backendPrint('$runtimeType: got ${docs.length} new changes!');

      if (kIsWeb || !_alwaysRunIsolate && docs.length < 0x10) {
        for (final SnapshotDoc doc in docs) {
          onData(data, doc);
        }
      } else {
        data = await Isolate.run(isolateCallback(data, docs));
      }
      notifyListeners();
    }, onError: backendPrint);
  }

  ValueGetter<T> isolateCallback(T current, SnapshotDocs docs);

  T data;

  late final StreamSubscription<QuerySnapshot<Json>> _streamSubscription;

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }
}

extension KeyValue on Widget {
  String get firestoreId => switch (key) {
        final FirestoreID id => id.value,
        _ => throw Exception('The key (${key.runtimeType}) should be a $FirestoreID'),
      };
}

extension DocMatcher on DocumentSnapshot<Json> {
  bool match(Widget widget) => widget.firestoreId == id;
}
