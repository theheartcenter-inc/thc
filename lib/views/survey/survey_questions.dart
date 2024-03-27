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

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    final String question = json['question'];
    final bool optional = json['optional'] ?? false;

    final String type = json['type'];
    switch (type.split(' ')) {
      case ['yesNo']:
        return YesNoQuestion(question, optional: optional);

      case ['textPrompt']:
        return TextPromptQuestion(question, optional: optional);

      case [final choicesType, 'multiple', 'choice']:
        final List<String> choices = json['choices'];
        final bool canType = json['custom response allowed'] ?? false;
        return switch (choicesType) {
          'radio' => RadioQuestion(
              question,
              optional: optional,
              choices: choices,
              canType: canType,
            ),
          'checkbox' || _ => CheckboxQuestion(
              question,
              optional: optional,
              choices: choices,
              canType: canType,
            ),
        };

      case ['scale']:
        return ScaleQuestion(
          question,
          optional: optional,
          values: json['values'],
          showEndLabels: json['show endpoint labels'] ?? false,
        );

      default:
        throw ArgumentError('couldn\'t parse "$type" into a question type.');
    }
  }

  /// The question text is stored in this string.
  final String description;

  /// Determines whether a red asterisk `*` should be displayed next to the question.
  ///
  /// If so, hitting "submit" won't work if the question hasn't been answered.
  final bool optional;

  /// Converts answer data into a readable text description.
  ///
  /// It returns `null` if there isn't a valid answer yet.
  String? answerDescription(covariant dynamic answer);

  Map<String, dynamic> get json => {'question': description, if (optional) 'optional': true};
}

/// {@template views.survey.YesNoQuestion}
/// Displays a segmented button with 2 options (yes/no).
/// {@endtemplate}
class YesNoQuestion extends SurveyQuestion {
  /// {@macro views.survey.YesNoQuestion}
  const YesNoQuestion(super.description, {super.optional = false});

  @override
  String? answerDescription(bool? answer) =>
      switch (answer) { true => 'yes', false => 'no', null => null };

  @override
  Map<String, dynamic> get json => {...super.json, 'type': 'yesNo'};
}

/// {@template views.survey.TextPromptQuestion}
/// Displays a text field, allowing the user to type a custom response.
/// {@endtemplate}
class TextPromptQuestion extends SurveyQuestion {
  /// {@macro views.survey.TextPromptQuestion}
  const TextPromptQuestion(super.description, {super.optional = false});

  @override
  String? answerDescription(String? answer) => answer.validated;

  @override
  Map<String, dynamic> get json => {...super.json, 'type': 'textPrompt'};
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

  int get totalChoices => choices.length + (canType ? 1 : 0);

  /// If true, an extra option will appear at the bottom of the list,
  /// allowing the user to type their own response.
  final bool canType;

  int? get typingIndex => canType ? choices.length : null;

  @override
  Map<String, dynamic> get json {
    final type = switch (this) {
      RadioQuestion() => 'radio',
      CheckboxQuestion() => 'checkbox',
    };

    return {
      ...super.json,
      'type': '$type multiple choice',
      'choices': choices,
      if (canType) 'custom response allowed': true,
    };
  }
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
class CheckboxQuestion extends MultipleChoice {
  /// {@macro views.survey.CheckboxQuestion}
  const CheckboxQuestion(
    super.description, {
    required super.choices,
    super.optional = false,
    super.canType = false,
  });

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
    return [for (final selection in selectedChoices) '☑ $selection'].join('\n');
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
    this.showEndLabels = false,
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
  String answerDescription(int? answer) => values[answer!];

  @override
  Map<String, dynamic> get json => {
        ...super.json,
        'type': 'scale',
        'values': values,
        if (showEndLabels) 'show endpoint labels': true,
      };
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

/// The goal of this [Enum] is to showcase different things you can do
/// with the current survey class implementations.
enum SurveyPresets {
  intro(
    label: 'intro survey',
    questions: [
      YesNoQuestion('Are you in need of meditation?'),
      CheckboxQuestion(
        'Please check all that apply:',
        choices: [
          'Currently incarcerated',
          'Have been incarcerated in the past',
          'Impacted by the incarceration of a loved one',
          'CDCR officer',
        ],
        optional: true,
      ),
      TextPromptQuestion(
        "Is there anything you'd like to share "
        'regarding your mental health or interest in meditation?',
        optional: true,
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
        showEndLabels: true,
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

  /// {@macro totally_not_a_waste_of_time}
  funQuiz(
    label: 'personality quiz',
    questions: [
      RadioQuestion(
        "Hey friends, it's Nate—this is something I made for fun.\n\n"
        'Answer these questions and find out how similar we are!',
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
  const FunQuiz(super.description) : super(values: scaleValues, optional: true);

  /// Set to `true` while you're taking the personality quiz.
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
}
