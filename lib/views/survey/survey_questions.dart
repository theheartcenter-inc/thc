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
sealed class SurveyQuestion {
  /// Since it's a sealed class, this constructor can't be used to create
  /// [SurveyQuestion] objects, but we still need it for defining the subclasses.
  const SurveyQuestion(this.description, {required this.optional});

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
  dynamic get initial;

  /// Converts the answer data into a readable text description.
  ///
  /// It returns `null` if there isn't a valid answer yet.
  String? answerDescription(dynamic answer);
}

/// {@template views.survey.YesNoQuestion}
/// Displays a segmented button with 2 options (yes/no).
/// {@endtemplate}
class YesNoQuestion extends SurveyQuestion {
  /// {@macro views.survey.YesNoQuestion}
  const YesNoQuestion(super.description, {super.optional = false});

  @override
  bool? get initial => null;
  @override
  String? answerDescription(covariant bool? answer) =>
      switch (answer) { true => 'yes', false => 'no', null => null };
}

/// {@template views.survey.TextPromptQuestion}
/// Displays a text field, allowing the user to type a custom response.
/// {@endtemplate}
class TextPromptQuestion extends SurveyQuestion {
  /// {@macro views.survey.TextPromptQuestion}
  const TextPromptQuestion(super.description, {super.optional = false});

  @override
  String get initial => '';
  @override
  String? answerDescription(covariant String? answer) => answer.validated;
}

/// {@macro views.survey.sealed_class}
///
/// We're using an `(AnswerType, String?)` tuple: a [String] is passed in when
/// the user types a custom value.
sealed class MultipleChoice extends SurveyQuestion {
  /// You can't make a [MultipleChoice] object using this constructor;
  /// it's here because [RadioQuestion] and [CheckboxQuestion] use it.
  const MultipleChoice(
    super.description, {
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
class RadioQuestion extends MultipleChoice {
  /// {@macro views.survey.RadioQuestion}
  const RadioQuestion(
    super.description, {
    required super.choices,
    super.optional = false,
    super.canType = false,
  });

  @override
  (int, String?)? get initial => null;
  @override
  String? answerDescription(covariant (int, String?)? answer) {
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
class CheckboxQuestion extends MultipleChoice {
  /// {@macro views.survey.CheckboxQuestion}
  const CheckboxQuestion(
    super.description, {
    required super.choices,
    super.optional = false,
    super.canType = false,
  });

  @override
  (List<bool>, String?) get initial =>
      (List.filled(choices.length + (canType ? 1 : 0), false), null);
  @override
  String? answerDescription(covariant (List<bool>, String?)? answer) {
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
class ScaleQuestion extends SurveyQuestion {
  /// {@macro views.survey.ScaleQuestion}
  ///
  /// The value of [optional] only determines whether an asterisk `*` is shown,
  /// since a [ScaleQuestion] is never considered to be "unanswered".
  const ScaleQuestion(
    super.description, {
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
  String answerDescription(covariant int? answer) => values[answer!];
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

/// {@template views.survey.SurveyRecord}
/// Extension types are great for when you want to make an existing type behave in a new way.
///
/// `SurveyRecord` takes a [Record] (a.k.a. "tuple") of question and answer data
/// and has methods that can validate the input and output a description of the answer.
/// {@endtemplate}
extension type SurveyRecord._((SurveyQuestion, dynamic) record) {
  /// {@macro views.survey.SurveyRecord}
  SurveyRecord(SurveyQuestion question, dynamic answer) : this._((question, answer));

  SurveyQuestion get question => record.$1;
  String? get answer => question.answerDescription(record.$2);

  bool get valid => question.optional || answer != null;
  QuestionSummary get summary => (question.description, answer);
}

/// This extension type combines 2 lists into a single list of [SurveyRecord]s
extension type SurveyData(List<SurveyRecord> data) {
  SurveyData.fromLists(List<SurveyQuestion> questions, List<dynamic> answers)
      : this([for (final (i, question) in questions.indexed) SurveyRecord(question, answers[i])]);

  /// Generates a list of `true`/`false` values based on whether each answer
  /// meets the requirements for submission.
  List<bool> get validation => [for (final record in data) record.valid];
  List<QuestionSummary> get surveySummary => [for (final record in data) record.summary];
}

/// The goal of this [Enum] is to showcase different things you can do
/// with the current survey class implementations.
enum SurveyPresets {
  intro(
    label: 'intro survey',
    questions: [
      YesNoQuestion('Are you in need of meditation?'),
      YesNoQuestion(
        'Are you a person impacted by incarceration directly '
        'and through a loved one or survivors too, including CDCR officers, '
        'and folx who are doing the work to end mass incarceration?',
      ),
      CheckboxQuestion(
        'Which meditation types are you interested in practicing?',
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
        'How are you feeling right now?',
        values: ['awful', 'not good', 'neutral', 'good', 'fantastic'],
      ),
      YesNoQuestion('Did you find this practice helpful?'),
      TextPromptQuestion(
        'Do you have any feedback for the streamer?',
        optional: true,
      ),
    ],
  ),
  streamEndedEarly(
    label: 'stream ended early',
    questions: [
      CheckboxQuestion(
        'What caused you to end the stream early?',
        choices: [
          'Discomfort/difficulty focusing',
          "The streamer's behavior",
          'Need to do something else',
          'False positive (I watched the entire stream)',
        ],
        canType: true,
      ),
      TextPromptQuestion(
        'Do you have any feedback for the streamer?',
        optional: true,
      ),
    ],
  ),

  /// {@template totally_not_a_waste_of_time}
  /// The cynical/critical folks may argue that this was a waste of time.
  ///
  /// But this quiz is undoubtedly a fantastic way to showcase how our survey format
  /// can be utilized and possibly expanded upon in the future.
  /// {@endtemplate}
  funQuiz(
    label: 'Nate%',
    questions: [
      RadioQuestion(
        'This is something I made for fun.\n\n'
        'Answer each question and find out how similar we are!',
        choices: ['Sounds good!'],
        optional: true,
      ),
      FunQuiz('having a dog 🐕'),
      FunQuiz('having a cat 🐈'),
      FunQuiz('creative writing ✍️'),
      FunQuiz('anime 🍙'),
      FunQuiz('Sonic the Hedgehog 🦔'),
      FunQuiz('DIY projects 🛠️'),
      FunQuiz('vegan diet 🥦'),
      FunQuiz('margaritas 🍸'),
      FunQuiz('shrooms 🍄'),
      FunQuiz('the color "cyan" 🩵'),
      FunQuiz('the movie "Nimona" 🩷'),
      FunQuiz('the show "Game of Thrones" ⚔️'),
      FunQuiz('swimming 🏊'),
      FunQuiz('cycling 🚲'),
      FunQuiz('rock climbing 🧗'),
      FunQuiz('football 🏈'),
      FunQuiz('traveling ✈️'),
      FunQuiz('singing 🎤'),
      FunQuiz('going to concerts ✨'),
      ScaleQuestion(
        'how tall? 📏',
        values: FunQuiz.heights,
        showEndLabels: false,
        optional: true,
      ),
    ],
  );

  /// By defining a constructor inside an enum, we can give it members
  /// in a way similar to a regular class definition.
  const SurveyPresets({required this.label, required this.questions});

  /// Stores the text shown on the button that links to the survey.
  final String label;
  final List<SurveyQuestion> questions;
}

/// {@macro totally_not_a_waste_of_time}
class FunQuiz extends ScaleQuestion {
  /// {@macro totally_not_a_waste_of_time}
  const FunQuiz(super.description)
      : super(showEndLabels: false, values: scaleValues, optional: true);

  /// Set to `true` while you're taking the Nate% quiz.
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
  static const myAnswers = [2, 3, 1, 2, 4, 1, 4, 0, 3, 4, 4, 1, 1, 4, 3, 0, 1, 4, 1, 7];

  @override
  int get initial => 2;
}
