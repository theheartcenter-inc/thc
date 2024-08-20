import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thc/home/surveys/survey_questions.dart';
import 'package:thc/the_good_stuff.dart';

typedef Json = Map<String, dynamic>;

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

  Stream<QuerySnapshot<Json>> snapshots({
    ListenSource source = ListenSource.defaultSource,
    bool includeMetadataChanges = false,
  }) {
    return _collection.snapshots(
      source: source,
      includeMetadataChanges: includeMetadataChanges,
    );
  }
}

extension GetData on DocumentReference<Json> {
  Future<Json?> getData() async {
    DocumentSnapshot<Json>? result;
    try {
      result = await get();
    } catch (e) {
      assert(false, 'got an error (type ${e.runtimeType})');
    }
    if (result == null) return null;
    assert(result.exists, "$path doesn't exist");
    final Json? data = result.data();
    backendPrint('data: $data');
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

  Future<DocumentReference<Json>> submitResponse(Json answerJson) =>
      _doc.collection('responses').add(answerJson);

  Future<void> yeetResponses() async {
    final QuerySnapshot<Json> responseDocs = await _doc.collection('responses').get();
    await Future.wait([
      for (final item in responseDocs.docs) item.reference.delete(),
    ]);
  }

  /// The number of questions in the survey.
  Future<int> getLength() async {
    final Json json = (await _doc.getData())!;
    return json['question count'];
  }

  Future<void> newLength(int length) async {
    if (kDebugMode && !(await _doc.get()).exists) {
      const message = 'tried to set the length for a non-existent survey';
      assert(false, message);
      await navigator.snackbarMessage(message);
      return _doc.set({'question count': length});
    }
    return _doc.update({'question count': length});
  }

  Future<List<SurveyQuestion>> getQuestions() async {
    final int length = await getLength();

    Future<SurveyQuestion> getQuestion(int i) async {
      final Json json = (await doc(i).getData())!;
      return SurveyQuestion.fromJson(json);
    }

    return Future.wait<SurveyQuestion>([for (int i = 0; i < length; i++) getQuestion(i)]);
  }
}

class FirestoreID extends ValueKey<String> {
  const FirestoreID(super.id);

  FirestoreID.doc(DocumentReference doc) : this(doc.id);

  FirestoreID.create(Firestore collection) : this.doc(collection.doc());
}
