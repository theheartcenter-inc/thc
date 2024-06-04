import 'package:flutter/widgets.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/firebase/firebase_bloc.dart';
import 'package:thc/home/schedule/schedule.dart';
import 'package:thc/utils/bloc.dart';

typedef StreamSchedule = List<ScheduledStreamCard>;

class ScheduledStreams extends FirebaseBloc<StreamSchedule> {
  ScheduledStreams() : super(Firestore.scheduled_streams.snapshots, data: [], onData: _onData);

  static _onData(StreamSchedule current, SnapshotDoc doc) {
    if (doc.data() case final json?) {
      final newScheduled = ScheduledStreamCard.fromJson(json, key: Key(doc.id));
      final int index = current.indexWhere(doc.match);
      if (index == -1) {
        current.add(newScheduled);
      } else {
        current[index] = newScheduled;
      }
    } else {
      current.removeWhere(doc.match);
    }
  }

  @override
  ValueGetter<StreamSchedule> isolateCallback(StreamSchedule current, SnapshotDocs docs) {
    return () {
      for (final SnapshotDoc doc in docs) {
        _onData(current, doc);
      }
      return current;
    };
  }

  static ({StreamSchedule active, StreamSchedule scheduled}) of(BuildContext context) {
    final StreamSchedule active = [], scheduled = [];
    for (final schedule in context.watch<ScheduledStreams>().data) {
      (schedule.active ? active : scheduled).add(schedule);
    }
    return (active: active, scheduled: scheduled);
  }
}
