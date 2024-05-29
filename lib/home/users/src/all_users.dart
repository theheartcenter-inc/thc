import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show QuerySnapshot;
import 'package:flutter/widgets.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/utils/app_config.dart';
import 'package:thc/utils/bloc.dart';

/// Same as `List<ThcUser>`, but you have the option to use the user ID or email
/// in place of the index.
extension type ThcUsers.fromList(List<ThcUser> users) implements Iterable<ThcUser> {
  ThcUsers() : this.fromList([]);

  factory ThcUsers.of(BuildContext context) => context.watch<AllUsers>().users;

  int index(Object key) {
    return switch (key) {
      int() when key >= 0 && key < users.length => key,
      int() => -1,
      ThcUser() => users.indexOf(key),
      String() => users.indexWhere((user) => user.matches(key)),
      _ => throw ArgumentError('not sure how to handle ${key.runtimeType}'),
    };
  }

  ThcUser operator [](Object key) => users[index(key)];

  void operator []=(dynamic key, ThcUser updated) {
    final i = index(key);
    backendPrint('index: $i, key: $key (type ${key.runtimeType})');
    if (i.isNegative) {
      users.add(updated);
    } else {
      users[i] = updated;
    }
  }

  dynamic yeet(dynamic key) {
    return switch (key) {
      ThcUser() => users.remove(key),
      String() => users.removeWhere((user) => user.matches(key)),
      int() => users.removeAt(key),
      _ => throw ArgumentError('not sure how to handle ${key.runtimeType}'),
    };
  }
}

class AllUsers with Bloc {
  AllUsers() {
    subscription = stream.listen((event) {
      for (final newStuff in event.docChanges) {
        final doc = newStuff.doc;
        if (doc.data() case final json?) {
          users[doc.id] = ThcUser.fromJson(json);
        } else {
          users.yeet(doc.id);
        }
      }
      notifyListeners();
    }, onError: backendPrint);
  }

  final users = ThcUsers();
  final stream = Firestore.users.snapshots();
  late final StreamSubscription<QuerySnapshot<Json>> subscription;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
