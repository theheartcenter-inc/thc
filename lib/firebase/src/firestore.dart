import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thc/home/surveys/survey_questions.dart';
import 'package:thc/utils/app_config.dart';
import 'package:thc/utils/navigator.dart';

typedef Json = Map<String, dynamic>;
typedef Snapshot = QuerySnapshot<Json>;

mixin CollectionName on Enum {
  @override
  String toString() => [
        for (final character in name.characters)
          if (character.toLowerCase() case final lowered when lowered != character)
            ' $lowered'
          else
            character
      ].join();
}

enum Firestore with CollectionName {
  streams,
  surveys,
  scheduled_streams, // ignore: constant_identifier_names
  users;

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

enum ThcSurvey with CollectionName {
  introSurvey,
  streamFinished,
  streamEndedEarly;

  /// A reference to the survey in Firebase.
  DocumentReference<Json> get _doc => Firestore.surveys.doc('$this');

  /// A reference to a question from this survey in Firebase.
  DocumentReference<Json> doc(int i) => _doc.collection('questions').doc('$i');

  /// The number of questions in the survey.
  Future<int?> getLength() async {
    final json = await _doc.getData();
    return json?['question count'];
  }

  Future<void> newLength(int length) async {
    if (kDebugMode && !(await _doc.get()).exists) {
      const message = 'tried to set the length for a non-existent survey';
      ErrorIfStrict(message);
      await navigator.showSnackBar(const SnackBar(content: Text(message)));
      return _doc.set({'question count': length});
    }
    return _doc.update({'question count': length});
  }

  Future<List<SurveyQuestion>> getQuestions() async {
    final defaults = SurveyPresets.values[index].questions;
    if (!useInternet) return Future.value(defaults);

    final length = await getLength();
    if (length == null) {
      ErrorIfStrict("the length of '$this' hasn't been set.");
      return defaults;
    }

    Future<SurveyQuestion> getQuestion(int i) async {
      final json = await doc(i).getData();
      return SurveyQuestion.fromJson(json!);
    }

    return Future.wait<SurveyQuestion>([for (int i = 0; i < length; i++) getQuestion(i)]);
  }
}
