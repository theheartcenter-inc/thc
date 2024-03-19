/// This file has no imports whatsoever, just pure Dart code. 😎
library;

extension ValidAnswer on String? {
  /// If the user just presses the spacebar a couple of times,
  /// it probably shouldn't count as a valid answer.
  String? get validated {
    final trimmed = this?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  /// Returns `true` if the user has typed a valid response.
  bool get valid => validated != null;
}

/// {@template views.survey.sealed_class}
/// When you make a `sealed` class, you're only allowed to extend or implement
/// the class if you're inside the same file.
///
/// Restricting the class this way means that you can use switch statements
/// or switch expressions, and Dart will understand when you've covered each
/// subclass, so no default case is needed.
/// {@endtemplate}
sealed class SurveyQuestion<AnswerType> {
  const SurveyQuestion({required this.description, required this.optional});

  /// The question text is stored in this string.
  final String description;

  /// Determines whether a red asterisk `*` should be displayed next to the question.
  ///
  /// If so, hitting "submit" won't work if the question hasn't been answered.
  final bool optional;

  /// {@template views.survey.AnswerType}
  /// The answer type is different for each type of question.
  ///
  /// It contains the data needed to determine the user's answer based on the question data.
  ///
  /// For example, in a [YesNoQuestion], the answer type is [bool]—
  /// a value of `true` means "yes" and a value of `false` means "no".
  /// {@endtemplate}
  AnswerType? get initial;

  /// This function is able to convert the answer data into a readable text description.
  ///
  /// It returns `null` if there isn't a valid answer yet.
  String? answerDescription(AnswerType? answer);
}

/// {@template views.survey.YesNoQuestion}
/// Displays a segmented button with 2 options (yes/no).
/// {@endtemplate}
class YesNoQuestion extends SurveyQuestion<bool> {
  /// {@macro views.survey.YesNoQuestion}
  const YesNoQuestion({required super.description, super.optional = false});
  @override
  bool? get initial => null;

  @override
  String? answerDescription(bool? answer) =>
      switch (answer) { true => 'yes', false => 'no', null => null };
}

/// {@template views.survey.TextPromptQuestion}
/// Displays a text field, allowing the user to type a custom response.
/// {@endtemplate}
class TextPromptQuestion extends SurveyQuestion<String> {
  /// {@macro views.survey.TextPromptQuestion}
  const TextPromptQuestion({required super.description, super.optional = false});
  @override
  String get initial => '';
  @override
  String? answerDescription(String? answer) => answer.validated;
}

/// {@macro views.survey.sealed_class}
///
/// We're using an `(AnswerType, String?)` tuple: a [String] is passed in when
/// the user types a custom value.
sealed class MultipleChoice<AnswerType> extends SurveyQuestion<(AnswerType, String?)> {
  /// You can't make a [MultipleChoice] object using this constructor;
  /// it's here because [RadioQuestion] and [CheckboxQuestion] use it.
  const MultipleChoice({
    required super.description,
    super.optional = false,
    required this.choices,
    this.canType = false,
  });

  /// Contains different options for the user to select.
  ///
  /// The number of choices will be `choices.length + 1`
  /// if [canType] is set to `true`.
  final List<String> choices;

  /// If true, an extra option will appear at the bottom of the list,
  /// allowing the user to type their own response.
  final bool canType;
}

/// {@template views.survey.RadioQuestion}
/// The standard multiple-choice format: there's a bunch of circles,
/// and you tap one of them to select it.
/// {@endtemplate}
///
/// The answer data is an [int] representing the index of the user's
/// selected choice.
class RadioQuestion extends MultipleChoice<int> {
  /// {@macro views.survey.RadioQuestion}
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

/// {@template views.survey.CheckboxQuestion}
/// A multiple-choice question with checkboxes next to each item,
/// so you can select one or more.
/// {@endtemplate}
///
/// The answer data is a list of [bool]s: each item is `true` or `false`
/// depending on whether the checkbox is selected.
class CheckboxQuestion extends MultipleChoice<List<bool>> {
  /// {@macro views.survey.CheckboxQuestion}
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

/// {@template views.survey.ScaleQuestion}
/// Shows a slider that allows the user to pick a value on a spectrum.
/// {@endtemplate}
class ScaleQuestion extends SurveyQuestion<int> {
  /// {@macro views.survey.ScaleQuestion}
  ///
  /// The value of [optional] only determines whether an asterisk `*` is shown,
  /// since a [ScaleQuestion] is never considered to be "unanswered".
  const ScaleQuestion({
    required super.description,
    super.optional = false,
    this.values = _defaults,
    this.showEndLabels = true,
  });

  /// {@template views.survey.endpoint_labels}
  /// The current selected value is always shown below the slider;
  /// setting [showEndLabels] as `true` will add small labels above the endpoints.
  /// {@endtemplate}
  final bool showEndLabels;
  final List<String> values;
  static const _defaults = [
    'strongly disagree',
    'disagree',
    'neutral',
    'agree',
    'strongly agree',
  ];

  /// {@macro views.survey.endpoint_labels}
  (String, String)? get endpoints => showEndLabels ? (values.first, values.last) : null;

  @override
  int get initial => 0;
  @override
  String answerDescription(int? answer) => values[answer!];
}

/// {@template views.survey.record_types}
/// Dart recently added [Record] types, which make several things more convenient.
///
/// ```dart
/// final record = (1, 2, 3, greeting: 'hello!');
///
/// // assign multiple variables at once!
/// // Use _ when you don't care about the value.
/// final (int first, int _, int third, greeting: String greeting) = record;
///
/// // same thing but shorter
/// final (first, _, third, :greeting) = record;
///
///
/// final List<String> list = ['a', 'b', 'c', 'd'];
/// // list.indexed is [(0, 'a'), (1, 'b'), (2, 'c'), (3, 'd')]
/// for (final (i, value) in list.indexed) {
///   print('$value, ${anotherList[i]}');
/// }
/// ```
/// {@endtemplate}
typedef QuestionSummary = (String question, String? answer);

/// {@template views.survey.extension_types}
/// Extension types are great for when you want to make an existing type behave in a new way.
/// {@endtemplate}
extension type SurveyRecord<AnswerType>._((SurveyQuestion<AnswerType>, AnswerType?) record) {
  /// {@macro views.survey.extension_types}
  SurveyRecord(SurveyQuestion<AnswerType> question, AnswerType? answer)
      : this._((question, answer));

  SurveyQuestion get question => record.$1;
  AnswerType? get answer => record.$2;

  bool get valid => question.optional || answered;
  bool get answered => switch (answer) {
        null || (null, _) => false,
        final String s => s.validated != null,
        (final answer, final String? userInput) => _validateInput(answer, userInput),
        _ => true,
      };

  bool _validateInput(dynamic answer, String? userInput) {
    final validInput = userInput.validated != null;
    switch (question as MultipleChoice) {
      case final CheckboxQuestion q:
        final checks = answer as List<bool>;
        if (!q.canType || validInput) return checks.contains(true);
        return checks.sublist(0, checks.length - 1).contains(true);

      case final RadioQuestion q:
        final index = answer as int;
        return validInput || index < q.choices.length;
    }
  }

  QuestionSummary get summary => (question.description, question.answerDescription(answer));
}

/// {@macro views.survey.extension_types}
extension type SurveyData(List<SurveyRecord> data) {
  /// {@macro views.survey.extension_types}
  SurveyData.fromLists(List<SurveyQuestion> questions, List<dynamic> answers)
      : this([for (final (i, question) in questions.indexed) SurveyRecord(question, answers[i])]);

  List<bool> get validation => [for (final record in data) record.valid];

  List<QuestionSummary> get surveySummary => [for (final record in data) record.summary];
}

/// The goal of this [Enum] is to showcase different things you can do
/// with the current survey class implementations.
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

  /// {@template totally_not_a_waste_of_time}
  /// The cynical/critical folks may argue that creating this quiz was a waste of time.
  ///
  /// But this fun little quiz is undoubtedly a fantastic way to showcase
  /// how this survey format can be utilized and possibly expanded upon in the future.
  /// {@endtemplate}
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

/// {@macro totally_not_a_waste_of_time}
class FunQuiz extends ScaleQuestion {
  /// {@macro totally_not_a_waste_of_time}
  const FunQuiz(String tag)
      : super(description: tag, showEndLabels: false, values: scaleValues, optional: true);

  /// `true` if someone is currently taking the "Nate%" quiz.
  ///
  /// Changes the survey "submit" button's behavior and a couple of theme colors.
  static bool inProgress = false;
  static const scaleValues = ['👎', "don't like", 'neutral', 'enjoy 👍', 'completely obsessed'];
  static const heights = [
    ...["4'10", "4'11"],
    ...["5'0", "5'1", "5'2", "5'3", "5'4", "5'5", "5'6", "5'7", "5'8", "5'9", "5'10", "5'11"],
    ...["6'0", "6'1", "6'2", "6'3", "6'4", "6'5", "6'6"],
  ];

  /// Match these values for a "100.0%"!
  static const myAnswers = [2, 3, 2, 4, 1, 4, 0, 3, 4, 4, 1, 2, 1, 4, 3, 0, 1, 4, 1, 7];

  @override
  int get initial => 2;
}
