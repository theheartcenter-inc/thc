import 'package:thc/firebase/firebase.dart';

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

/// {@template sealed_class}
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

  factory SurveyQuestion.fromJson(Json json) {
    final String question = json['question'];
    final bool optional = json['optional'] ?? false;

    final String type = json['type'];
    switch (type.split(' ')) {
      case ['yes/no']:
        return YesNoQuestion(question, optional: optional);

      case ['text prompt']:
        return TextPromptQuestion(question, optional: optional);

      case [final choicesType, 'multiple', 'choice']:
        final choices = <String>[...json['choices']];
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
        final values = <String>[...json['values']];
        return ScaleQuestion(
          question,
          optional: optional,
          values: values,
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

  Json get json => {'question': description, if (optional) 'optional': true};
}

/// {@template YesNoQuestion}
/// Displays a segmented button with 2 options (yes/no).
/// {@endtemplate}
class YesNoQuestion extends SurveyQuestion {
  /// {@macro YesNoQuestion}
  const YesNoQuestion(super.description, {super.optional = false});

  @override
  String? answerDescription(bool? answer) =>
      switch (answer) { true => 'yes', false => 'no', null => null };

  @override
  Json get json => {...super.json, 'type': 'yes/no'};
}

/// {@template TextPromptQuestion}
/// Displays a text field, allowing the user to type a custom response.
/// {@endtemplate}
class TextPromptQuestion extends SurveyQuestion {
  /// {@macro TextPromptQuestion}
  const TextPromptQuestion(super.description, {super.optional = false});

  @override
  String? answerDescription(String? answer) => answer.validated;

  @override
  Json get json => {...super.json, 'type': 'text prompt'};
}

/// {@macro sealed_class}
///
/// We're using an `(AnswerType, String?)` tuple: a [String] is passed in when
/// the user types a custom value.
sealed class MultipleChoice extends SurveyQuestion {
  /// {@template MultipleChoice_answer}
  /// [MultipleChoice] questions have answers stored as tuples:
  /// the first value is information about which answer(s) are selected,
  /// and the second value can contain a custom text response that the user typed in.
  /// {@endtemplate}
  const MultipleChoice(
    super.description, {
    super.optional = false,
    this.choices = const ['option 1', 'option 2'],
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
  Json get json {
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

/// {@template RadioQuestion}
/// The standard multiple-choice format: there's a bunch of circles,
/// and you tap one of them to select it.
/// {@endtemplate}
///
/// The answer data is an [int] representing the index of the user's
/// selected choice.
class RadioQuestion extends MultipleChoice {
  /// {@macro RadioQuestion}
  const RadioQuestion(
    super.description, {
    super.choices,
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

/// {@template CheckboxQuestion}
/// A multiple-choice question with checkboxes next to each item,
/// so you can select one or more.
/// {@endtemplate}
///
/// The answer data is a list of [bool]s: each item is `true` or `false`
/// depending on whether the checkbox is selected.
class CheckboxQuestion extends MultipleChoice {
  /// {@macro CheckboxQuestion}
  const CheckboxQuestion(
    super.description, {
    super.choices,
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

/// {@template ScaleQuestion}
/// Shows a slider that allows the user to pick a value on a spectrum.
/// {@endtemplate}
class ScaleQuestion extends SurveyQuestion {
  /// {@macro ScaleQuestion}
  ///
  /// The value of [optional] only determines whether an asterisk `*` is shown,
  /// since a [ScaleQuestion] is never considered to be "unanswered".
  const ScaleQuestion(
    super.description, {
    super.optional = false,
    this.values = _defaults,
    this.showEndLabels = false,
  });

  /// {@template endpoint_labels}
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

  /// {@macro endpoint_labels}
  (String, String)? get endpoints => showEndLabels ? (values.first, values.last) : null;

  @override
  String answerDescription(int? answer) => values[answer!];

  @override
  Json get json => {
        ...super.json,
        'type': 'scale',
        'values': values,
        if (showEndLabels) 'show endpoint labels': true,
      };
}

/// {@template record_types}
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
