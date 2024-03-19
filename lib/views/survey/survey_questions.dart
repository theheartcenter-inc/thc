/// This file has no imports whatsoever, just pure Dart code. 😎
library;

extension ValidAnswer on String? {
  String? get validated {
    final trimmed = this?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }
}

sealed class SurveyQuestion<AnswerType> {
  const SurveyQuestion({required this.description, required this.optional});

  final String description;
  final bool optional;
  AnswerType? get initial;
  String? answerDescription(AnswerType? answer);
}

class YesNoQuestion extends SurveyQuestion<bool> {
  const YesNoQuestion({required super.description, super.optional = false});
  @override
  bool? get initial => null;

  @override
  String? answerDescription(bool? answer) =>
      switch (answer) { true => 'yes', false => 'no', null => null };
}

class TextPromptQuestion extends SurveyQuestion<String> {
  const TextPromptQuestion({required super.description, super.optional = false});
  @override
  String get initial => '';
  @override
  String? answerDescription(String? answer) => answer.validated;
}

abstract class MultipleChoice<AnswerType> extends SurveyQuestion<(AnswerType, String?)> {
  const MultipleChoice({
    required super.description,
    super.optional = false,
    required this.choices,
    this.canType = false,
  });

  final List<String> choices;
  final bool canType;
}

class RadioQuestion extends MultipleChoice<int> {
  const RadioQuestion({
    required super.description,
    required super.choices,
    super.optional = false,
    super.canType = false,
  });
  @override
  (int, String?)? get initial => null;
  @override
  String? answerDescription((int, String?)? answer) {
    if (answer == null) return null;

    final (index, userInput) = answer;
    if (index < choices.length) return choices[index];

    return userInput.validated;
  }
}

class CheckboxQuestion extends MultipleChoice<List<bool>> {
  const CheckboxQuestion({
    required super.description,
    required super.choices,
    super.optional = false,
    super.canType = false,
  });
  @override
  (List<bool>, String?) get initial =>
      (List.filled(choices.length + (canType ? 1 : 0), false), null);
  @override
  String? answerDescription((List<bool>, String?)? answer) {
    final (checks, userInput) = answer!;
    if (!checks.contains(true)) return null;

    final selectedChoices = [
      for (final (i, choice) in choices.indexed)
        if (checks[i]) choice,
      if (canType && checks[choices.length])
        if (userInput.validated case final String userAnswer) userAnswer,
    ];

    if (selectedChoices.isEmpty) return null;
    return selectedChoices.join(', ');
  }
}

class ScaleQuestion extends SurveyQuestion<int> {
  const ScaleQuestion({
    required super.description,
    super.optional = false,
    List<String>? values,
    this.showEndLabels = true,
  }) : _values = values ?? _defaults;

  final bool showEndLabels;
  final List<String> _values;
  static const _defaults = [
    'strongly disagree',
    'disagree',
    'neutral',
    'agree',
    'strongly agree',
  ];

  (String, String)? get endpoints => showEndLabels ? (_values.first, _values.last) : null;
  int get length => _values.length;
  String operator [](int index) => _values[index];

  @override
  int get initial => 0;
  @override
  String answerDescription(int? answer) => this[answer!];
}

typedef QuestionSummary = (String question, String? answer);

extension type SurveyRecord<AnswerType>._((SurveyQuestion<AnswerType>, AnswerType?) record) {
  SurveyRecord(SurveyQuestion<AnswerType> question, AnswerType? answer)
      : this._((question, answer));

  SurveyQuestion get question => record.$1;
  AnswerType? get answer => record.$2;

  bool get valid => question.optional || answered;
  bool get answered => switch (answer) {
        null || (null, _) => false,
        final String s => s.validated != null,
        (final answer, final String? userInput) => validateInput(answer, userInput),
        _ => true,
      };

  bool validateInput(dynamic answer, String? userInput) {
    final validInput = userInput.validated != null;
    switch ((question, answer)) {
      case (final CheckboxQuestion q, final List<bool> checks):
        if (!q.canType || validInput) return checks.contains(true);
        return checks.sublist(0, checks.length - 1).contains(true);

      case (final RadioQuestion q, final int index):
        return validInput || index < q.choices.length;

      default:
        throw ArgumentError(
          'question is ${question.runtimeType}, answer is ${answer.runtimeType}',
        );
    }
  }

  QuestionSummary get summary => (question.description, question.answerDescription(answer));
}

extension type SurveyData(List<SurveyRecord> data) {
  SurveyData.fromLists(List<SurveyQuestion> questions, List<dynamic> answers)
      : this([for (final (i, question) in questions.indexed) SurveyRecord(question, answers[i])]);

  List<bool> get validation => [for (final record in data) record.valid];

  List<QuestionSummary> get surveySummary => [for (final record in data) record.summary];
}

enum SurveyPresets {
  intro(
    label: 'intro survey',
    questions: [
      YesNoQuestion(description: 'Are you in need of meditation?'),
      YesNoQuestion(
        description: 'Are you a person impacted by incarceration directly '
            'and through a loved one or survivors too, including CDCR officers, '
            'and folx who are doing the work to end mass incarceration?',
      ),
      CheckboxQuestion(
        description: 'Which meditation types are you interested in practicing?',
        choices: [
          'Mindfulness',
          'Metta (Loving-Kindness)',
          'Tai Chi (moving meditation)',
          'Mantra (chanting)',
          'Zen (focus)',
        ],
        optional: true,
      ),
    ],
  ),
  streamFinished(
    label: 'after finishing stream',
    questions: [
      ScaleQuestion(
        description: 'How are you feeling right now?',
        values: ['awful', 'not good', 'neutral', 'good', 'fantastic'],
      ),
      YesNoQuestion(description: 'Did you find this practice helpful?'),
      TextPromptQuestion(
        description: 'Do you have any feedback for the streamer?',
        optional: true,
      ),
    ],
  ),
  streamEndedEarly(
    label: 'stream ended early',
    questions: [
      CheckboxQuestion(
        description: 'What caused you to end the stream early?',
        choices: [
          'Discomfort/difficulty focusing',
          "The streamer's behavior",
          'Need to do something else',
          'False positive (I watched the entire stream)',
        ],
        canType: true,
      ),
      TextPromptQuestion(
        description: 'Do you have any feedback for the streamer?',
        optional: true,
      ),
    ],
  ),
  funQuiz(
    label: 'Nate%',
    questions: [
      RadioQuestion(
        description: 'This is just something I made for fun.\n\n'
            'Answer each question and find out how similar we are!',
        choices: ['Sounds good!'],
        optional: true,
      ),
      FunQuiz('having a dog 🐕'),
      FunQuiz('having a cat 🐈'),
      FunQuiz('anime 🍙'),
      FunQuiz('Sonic the Hedgehog 🦔'),
      FunQuiz('DIY projects 🛠️'),
      FunQuiz('vegan diet 🥦'),
      FunQuiz('margaritas 🍸'),
      FunQuiz('shrooms 🍄'),
      FunQuiz('the color "cyan" 🩵'),
      FunQuiz('the movie "Nimona" 🩷'),
      FunQuiz('the show "Game of Thrones" ⚔️'),
      FunQuiz('capitalism 🪙'),
      FunQuiz('swimming 🏊'),
      FunQuiz('cycling 🚲'),
      FunQuiz('rock climbing 🧗'),
      FunQuiz('football 🏈'),
      FunQuiz('traveling ✈️'),
      FunQuiz('singing 🎤'),
      FunQuiz('creative writing ✍️'),
      ScaleQuestion(
        description: 'how tall? 📏',
        values: FunQuiz.heights,
        showEndLabels: false,
        optional: true,
      ),
    ],
  );

  const SurveyPresets({required this.label, required this.questions});

  final String label;
  final List<SurveyQuestion> questions;
}

class FunQuiz extends ScaleQuestion {
  const FunQuiz(String tag)
      : super(description: tag, showEndLabels: false, values: scaleValues, optional: true);

  static bool inProgress = false;
  static const scaleValues = ['👎', "don't like", 'neutral', 'enjoy 👍', 'completely obsessed'];
  static const heights = [
    ...["4'10", "4'11"],
    ...["5'0", "5'1", "5'2", "5'3", "5'4", "5'5", "5'6", "5'7", "5'8", "5'9", "5'10", "5'11"],
    ...["6'0", "6'1", "6'2", "6'3", "6'4", "6'5", "6'6"],
  ];
  static const myAnswers = [2, 3, 2, 4, 1, 4, 0, 3, 4, 4, 1, 2, 1, 4, 3, 0, 1, 4, 1, 7];

  @override
  int get initial => 2;
}
