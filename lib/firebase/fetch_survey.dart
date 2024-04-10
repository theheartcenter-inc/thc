import 'package:cloud_firestore/cloud_firestore.dart';

// Data model for a survey question
class SurveyQuestion {
  final String id;
  final String text;

  SurveyQuestion({required this.id, required this.text});

  factory SurveyQuestion.fromSnapshot(DocumentSnapshot snapshot) {
    return SurveyQuestion(
      id: snapshot.id,
      text: snapshot['text'],
    );
  }
}

// Firebase service to interact with Firestore
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetches survey questions for a given participant
  Stream<List<SurveyQuestion>> getSurveyQuestionsForParticipant(
      String participantId) {
    return _firestore
        .collection('users')
        .doc(participantId)
        .collection('survey_questions')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SurveyQuestion.fromSnapshot(doc))
          .toList();
    });
  }
}

void main() {
  FirebaseService firebaseService = FirebaseService();
  String participantId =
      'test_participant'; 

  firebaseService
      .getSurveyQuestionsForParticipant(participantId)
      .listen((questions) {
    print(
        'Received ${questions.length} survey questions for participant $participantId:');
    for (var question in questions) {
      print('${question.id}: ${question.text}');
    }
  });
}
