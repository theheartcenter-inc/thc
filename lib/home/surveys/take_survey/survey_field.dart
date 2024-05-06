// ignore_for_file: avoid_renaming_method_parameters, type_annotate_public_apis

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/home/surveys/survey_questions.dart';
import 'package:thc/home/surveys/take_survey/survey.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';

/// {@template SurveyField}
/// A widget that displays a survey question.
/// {@endtemplate}
class SurveyField extends StatelessWidget {
  /// {@macro SurveyField}
  const SurveyField(this.record, this.update, {super.key});

  /// {@macro SurveyRecord}
  final SurveyRecord record;

  /// {@template ValueChanged}
  /// For a very long time, I had no idea what [ValueChanged] was;
  /// then I realized it's just a function signature.
  ///
  /// 2 ways to write the same thing:
  /// ```dart
  /// final ValueChanged<int> onChanged;
  /// final void Function(int) onChanged;
  /// ```
  /// {@endtemplate}
  final ValueChanged<dynamic> update;

  @override
  Widget build(BuildContext context) {
    final builder = SurveyBuilder.fromRecord(record);
    final question = _QuestionText(record.question);
    final answer = builder.buildAnswer(context, update, record.question, record.cleanAnswer);

    return _ErrorBox(
      valid: record.valid || !context.watch<ValidSurveyAnswers>().state,
      child: builder.layout(context, question, answer),
    );
  }
}

/// {@template SurveyRecord}
/// Extension types are great for when you want to make an existing type behave in a new way.
///
/// `SurveyRecord` takes a [Record] of question and answer data
/// and has methods that can validate the input and output a description of the answer.
/// {@endtemplate}
extension type SurveyRecord.fromRecord((SurveyQuestion, dynamic) record) {
  /// {@macro SurveyRecord}
  SurveyRecord(SurveyQuestion question, dynamic answer) : this.fromRecord((question, answer));

  SurveyRecord.init(SurveyQuestion question) : this(question, initialAnswer(question));

  static initialAnswer(SurveyQuestion question) => switch (question) {
        ScaleQuestion() => 0,
        TextPromptQuestion() => '',
        final CheckboxQuestion question => (List.filled(question.totalChoices, false), null),
        YesNoQuestion() || RadioQuestion() => null,
      };

  SurveyQuestion get question => record.$1;
  dynamic get answer => record.$2;

  /// [MultipleChoice] questions have answers stored as tuples:
  /// the first value is information about which answer(s) are selected,
  /// and the second value can contain a custom text response that the user typed in.
  ///
  /// This getter ignores the second value and returns the data showing what's been selected.
  dynamic get cleanAnswer => switch (answer) { (final a, _) || final a => a };

  /// In order for the user to finish the survey, all non-optional questions must be answered.
  bool get valid => question.optional || question.answerDescription(answer) != null;

  /// Contains text that describes the question & answer.
  QuestionSummary get summary => (question.description, question.answerDescription(answer));
}

extension type SurveyData(List<SurveyRecord> data) implements List<SurveyRecord> {
  /// This constructor turns a list of questions into a list of [SurveyRecord]s:
  ///
  /// ```dart
  /// final List<SurveyQuestion> questions = [question1, question2, question3];
  ///
  /// // SurveyData.fromQuestions(questions)
  /// [
  ///   SurveyRecord(question1, answer1),
  ///   SurveyRecord(question2, answer2),
  ///   SurveyRecord(question3, answer3),
  /// ]
  /// ```
  SurveyData.fromQuestions(List<SurveyQuestion> questions)
      : this([for (final question in questions) SurveyRecord.init(question)]);

  /// Generates a list of `true`/`false` values based on whether each answer
  /// meets the requirements for submission.
  bool get valid => data.every((record) => record.valid);
  int get invalidCount => data.fold(0, (previous, record) => previous + (record.valid ? 0 : 1));

  /// The "fun quiz" only uses [ScaleQuestion]s, so its answer output can be an [int] list.
  List<int> get funQuizResults => [for (final record in data.sublist(1)) record.answer];

  /// Contains text that describes each question & answer.
  List<QuestionSummary> get summary => [for (final record in data) record.summary];
}

/// {@macro ValidSurveyAnswers}
class _ErrorBox extends StatelessWidget {
  /// {@macro ValidSurveyAnswers}
  const _ErrorBox({required this.valid, required this.child});

  final bool valid;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: ColoredBox(
        color: valid ? Colors.transparent : ThcColors.of(context).errorContainer,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: child,
        ),
      ),
    );
  }
}

/// {@template QuestionText}
/// Displays the question text, and adds an asterisk `*` to any non-optional question.
/// {@endtemplate}
class _QuestionText extends StatelessWidget {
  /// {@macro QuestionText}
  const _QuestionText(this.question);

  final SurveyQuestion question;

  @override
  Widget build(BuildContext context) {
    final colors = ThcColors.of(context);
    final style = StyleText(
      size: 16,
      weight: 500,
      shadows: [
        if (colors.brightness == Brightness.dark) Shadow(color: colors.background, blurRadius: 1),
      ],
    );
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            if (!question.optional)
              Transform.translate(
                offset: const Offset(-11, -3),
                child: Text('*', style: StyleText(size: 20, color: colors.error)),
              ),
            Text(question.description, style: style),
          ],
        ),
      ),
    );
  }
}

/// {@template MultipleChoiceTheme}
/// Unlike [_TextPrompt], the [MultipleChoice] questions that allow typed responses
/// have an [UnderlineInputBorder], thanks to this widget.
/// {@endtemplate}
class _MultipleChoiceTyping extends StatelessWidget {
  /// {@macro MultipleChoiceTheme}
  const _MultipleChoiceTyping({required this.onChanged, required this.onSubmitted});

  final dynamic onChanged, onSubmitted;

  @override
  Widget build(BuildContext context) {
    final colors = ThcColors.of(context);
    final enabled = BorderSide(color: colors.onBackground);
    final focused = BorderSide(color: colors.primaryContainer, width: 1.5);
    return Row(
      children: [
        const Text('(other) '),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(borderSide: enabled),
              focusedBorder: UnderlineInputBorder(borderSide: focused),
              isDense: true,
            ),
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ),
      ],
    );
  }
}

/// {@template SurveyBuilder}
/// These builder classes make it so we don't need a chonky `build()` method.
///
/// Each survey builder implements a [buildAnswer] method, and can also
/// override the [layout] if necessary.
/// {@endtemplate}
abstract class SurveyBuilder<Q extends SurveyQuestion> {
  /// If we remove this constructor, the subclasses get mad :(
  const SurveyBuilder();

  /// {@macro SurveyBuilder}
  factory SurveyBuilder.fromRecord(SurveyRecord record) => switch (record.question) {
        YesNoQuestion() => _YesNo(),
        TextPromptQuestion() => _TextPrompt(),
        CheckboxQuestion() => _Checkbox(),
        RadioQuestion() => _Radio(),
        ScaleQuestion() => _Scale(),
      } as SurveyBuilder<Q>;

  /// The question & answer are arranged vertically by default.
  ///
  /// But in the case of [YesNoQuestion], they're placed side-by-side.
  Widget layout(BuildContext context, Widget question, Widget answer) {
    return Column(children: [question, answer, const SizedBox(height: 20)]);
  }

  /// {@macro SurveyBuilder}
  Widget buildAnswer(BuildContext context, ValueChanged update, Q question, covariant _);
}

class _YesNo extends SurveyBuilder<YesNoQuestion> {
  @override
  Widget layout(context, question, answer) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: question),
        Padding(padding: const EdgeInsets.all(20), child: answer),
      ],
    );
  }

  @override
  Widget buildAnswer(context, update, question, bool? saidYes) {
    return SegmentedButton<bool>(
      showSelectedIcon: false,
      emptySelectionAllowed: true,
      segments: const [
        ButtonSegment(
          value: true,
          label: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('yes')),
        ),
        ButtonSegment(
          value: false,
          label: Padding(padding: EdgeInsets.only(right: 6), child: Text('no')),
        ),
      ],
      selected: {if (saidYes != null) saidYes},
      onSelectionChanged: (newAnswer) => update(newAnswer.firstOrNull ?? saidYes),
    );
  }
}

class _TextPrompt extends SurveyBuilder<TextPromptQuestion> {
  @override
  Widget buildAnswer(context, update, question, _) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(onChanged: update),
    );
  }
}

class _Radio extends SurveyBuilder<RadioQuestion> {
  @override
  Widget buildAnswer(context, update, question, int? index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, choice) in question.choices.indexed)
          RadioListTile<int>(
            title: Text(choice),
            value: i,
            groupValue: index,
            onChanged: (newValue) => update((newValue, null)),
          ),
        if (question.typingIndex case final i?)
          RadioListTile<int>(
            title: _MultipleChoiceTyping(
              onChanged: (userInput) => update((null, userInput)),
              onSubmitted: (userInput) => update((i, userInput)),
            ),
            value: i,
            groupValue: index,
            onChanged: (newValue) => update((newValue, null)),
          ),
      ],
    );
  }
}

class _Checkbox extends SurveyBuilder<CheckboxQuestion> {
  @override
  Widget buildAnswer(context, update, question, List<bool> checks) {
    void updateSelected(int i, [String? input]) {
      final selected = checks.toList();
      selected[i] = !selected[i];
      update((selected, input));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, choice) in question.choices.indexed)
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(choice),
            value: checks[i],
            onChanged: (_) => updateSelected(i),
          ),
        if (question.typingIndex case final i?)
          CheckboxListTile(
            controlAffinity: ListTileControlAffinity.leading,
            title: _MultipleChoiceTyping(
              onChanged: (userInput) => update((null, userInput)),
              onSubmitted: (userInput) => updateSelected(i, userInput),
            ),
            value: checks[i],
            onChanged: (_) => updateSelected(i),
          ),
      ],
    );
  }
}

class _Scale extends SurveyBuilder<ScaleQuestion> {
  @override
  Widget buildAnswer(context, update, question, int value) {
    final divisions = question.values.length - 1;
    return LayoutBuilder(builder: (context, constraints) {
      final theme = Theme.of(context);
      final colors = theme.colorScheme;
      final textTheme = theme.textTheme;
      final sliderWidth = constraints.maxWidth - 100;
      final labelOffset = Offset(sliderWidth / 2 - 25, 0);
      final double spacing = question.endpoints == null ? 0 : 10;

      return Stack(
        alignment: Alignment.topCenter,
        children: [
          if (question.endpoints case final ends?)
            for (final shift in const [-1.0, 1.0])
              Transform.translate(
                offset: labelOffset * shift,
                child: Text(
                  shift < 0 ? ends.$1 : ends.$2,
                  style: textTheme.labelMedium,
                ),
              ),
          Padding(
            padding: EdgeInsets.only(top: spacing),
            child: SizedBox(
              width: sliderWidth,
              child: Slider.adaptive(
                activeColor: Color.lerp(
                  colors.primary,
                  context.lightDark(colors.background, colors.secondary),
                  value / divisions,
                ),
                divisions: divisions,
                max: divisions.toDouble(),
                value: value.toDouble(),
                onChanged: (newValue) => update(newValue.round()),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 45 + spacing),
            child: Text(question.values[value], style: textTheme.labelLarge),
          ),
        ],
      );
    });
  }
}
