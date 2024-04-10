import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thc/firebase/firebase.dart';

// Data model for a survey question
class SurveySnapshot {
  SurveySnapshot({required this.id, required this.text});

  factory SurveySnapshot.fromSnapshot(DocumentSnapshot snapshot) {
    return SurveySnapshot(
      id: snapshot.id,
      text: snapshot['text'],
    );
  }

  final String id;
  final String text;
}

// Firebase service to interact with Firestore
Stream<List<SurveySnapshot>> getSurveyQuestionsForParticipant(String participantId) {
  return db
      .collection('users')
      .doc(participantId)
      .collection('survey_questions')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map(SurveySnapshot.fromSnapshot).toList();
  });
}
