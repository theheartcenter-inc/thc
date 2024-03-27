class IntroSurveyModel {
  // Can be the user story, the influence by incarceration, and why need meditation.

  // Constructor
  IntroSurveyModel({
    required this.surveyId,
    required this.userId,
    required this.age,
    required this.needMeditation,
    required this.impactedByIncarceration,
    this.incarcerationId,
    this.gender,
    this.ethnicity,
    this.incarcerationLength,
    this.educationLevel,
  });

  // Factory method to create an IntroSurveyModel from a map, which could be useful for fetching survey data from a database.
  factory IntroSurveyModel.fromSnapshot(/*DocumentSnapshot*/ dynamic snapshot) {
    return IntroSurveyModel(
      surveyId: snapshot['surveyId'],
      userId: snapshot['userId'],
      age: snapshot['age'],
      needMeditation: snapshot['needMeditation'],
      impactedByIncarceration: snapshot['impactedByIncarceration'],
      incarcerationId: snapshot['incarcerationId'],
      gender: snapshot['gender'],
      ethnicity: snapshot['ethnicity'],
      incarcerationLength: snapshot['incarcerationLength'],
      educationLevel: snapshot['educationLevel'],
    );
  }
  String surveyId; // A unique identifier for each Survey.
  String userId; // A unique identifier for each respondent (Foreign Key).
  String? incarcerationId; // An identifier within the prison system, if allowed and anonymized.
  int age; // Age of the respondent.
  bool needMeditation; // If need meditation or not.
  String? gender; // Gender of the respondent (optional).
  String? ethnicity; // Ethnicity of the respondent (optional).
  String? incarcerationLength; // Length of time incarcerated or time left (optional).
  String? educationLevel; // Highest level of education achieved (optional).
  String impactedByIncarceration;

  // Method to convert a survey model into a map, which could be useful for storing the survey data in a database.
  Map<String, dynamic> toDocument() => {
        'surveyId': surveyId,
        'userId': userId,
        'incarcerationId': incarcerationId,
        'age': age,
        'needMeditation': needMeditation,
        'gender': gender,
        'ethnicity': ethnicity,
        'incarcerationLength': incarcerationLength,
        'educationLevel': educationLevel,
        'impactedByIncarceration': impactedByIncarceration,
      };
}
