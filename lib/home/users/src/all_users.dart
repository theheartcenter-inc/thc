import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/firebase/firebase_bloc.dart';

class ThcUsers extends FirebaseBloc<List<ThcUser>> {
  ThcUsers() : super(Firestore.users.snapshots, data: [], onData: _onData);

  static void _onData(List<ThcUser> current, SnapshotDoc doc) {
    if (doc.data() case final json?) {
      final newUser = ThcUser.fromJson(json);
      final int index = current.indexWhere((user) {
        int matches = 0;
        if (user.name == newUser.name) matches++;
        if ((user.id, newUser.id) case (final p0?, final p1?) when p0 == p1) matches++;
        if ((user.email, newUser.email) case (final p0?, final p1?) when p0 == p1) matches++;
        return matches > 1;
      });
      if (index == -1) {
        current.add(newUser);
      } else {
        current[index] = user;
      }
    } else {
      current.removeWhere((user) => user.firestoreId == doc.id);
    }
  }

  @override
  ValueGetter<List<ThcUser>> isolateCallback(List<ThcUser> current, SnapshotDocs docs) {
    return () {
      for (final SnapshotDoc doc in docs) {
        _onData(current, doc);
      }
      return current;
    };
  }

  static List<ThcUser> of(BuildContext context, {String? filter}) {
    final users = context.watch<ThcUsers>().data;
    if (filter == null) return users;

    filter = filter.toLowerCase();
    return [
      for (final ThcUser user in users)
        if (user.name.toLowerCase().contains(filter) ||
            user.firestoreId.toLowerCase().contains(filter))
          user,
    ];
  }
}
