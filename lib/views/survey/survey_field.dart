// ignore_for_file: avoid_renaming_method_parameters, type_annotate_public_apis

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/survey/survey_questions.dart';
import 'package:thc/views/survey/survey_screen.dart';

class SurveyField extends StatelessWidget {
  const SurveyField(this.record, this.update, {super.key});

  final SurveyRecord record;
  final ValueChanged<dynamic> update;

  @override
  Widget build(BuildContext context) {
    final builder = SurveyBuilder.fromRecord(record);

    final question = QuestionText(record.question);
    final answer = builder.buildAnswer(context, update, record.question, record.cleanAnswer);

    return ErrorBox(
      valid: record.valid || !context.watch<SurveyValidation>().state,
      child: builder.fieldLayout(context, question, answer),
    );
  }
}

/// {@template views.survey.SurveyRecord}
/// Extension types are great for when you want to make an existing type behave in a new way.
///
/// `SurveyRecord` takes a [Record] of question and answer data
/// and has methods that can validate the input and output a description of the answer.
/// {@endtemplate}
extension type SurveyRecord.fromRecord((SurveyQuestion, dynamic) record) {
  /// {@macro views.survey.SurveyRecord}
  SurveyRecord(SurveyQuestion question, dynamic answer) : this.fromRecord((question, answer));

  SurveyQuestion get question => record.$1;
  dynamic get answer => record.$2;
  dynamic get cleanAnswer => switch (answer) { (final a, _) || final a => a };

  bool get valid => question.optional || question.answerDescription(answer) != null;
  QuestionSummary get summary => (question.description, question.answerDescription(answer));
}

/// This extension type combines 2 lists into a single list of [SurveyRecord]s
extension type SurveyData(List<SurveyRecord> data) implements List<SurveyRecord> {
  SurveyData.fromQuestions(List<SurveyQuestion> questions)
      : this([for (final question in questions) SurveyRecord(question, question.initial)]);

  /// Generates a list of `true`/`false` values based on whether each answer
  /// meets the requirements for submission.
  bool get valid => data.every((record) => record.valid);
  int get invalidCount => data.fold(0, (previous, record) => previous + (record.valid ? 0 : 1));

  List<dynamic> get answers => [for (final record in data) record.answer];
  List<QuestionSummary> get surveySummary => [for (final record in data) record.summary];
}

class ErrorBox extends StatelessWidget {
  const ErrorBox({required this.valid, super.key, required this.child});
  final bool valid;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: ColoredBox(
        color: valid ? Colors.transparent : context.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: child,
        ),
      ),
    );
  }
}

class QuestionText extends StatelessWidget {
  const QuestionText(this.question, {super.key});
  final SurveyQuestion question;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final style = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      shadows: [
        if (context.theme.brightness == Brightness.dark)
          Shadow(color: colors.background, blurRadius: 1),
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
                child: Text('*', style: TextStyle(fontSize: 20, color: colors.error)),
              ),
            Text(question.description, style: style),
          ],
        ),
      ),
    );
  }
}

class MultipleChoiceTheme extends Theme {
  MultipleChoiceTheme({super.key, required ColorScheme colors, required super.child})
      : super(data: _data(colors));

  static _data(ColorScheme colors) {
    final enabled = BorderSide(color: colors.onBackground);
    final focused = BorderSide(color: colors.primaryContainer, width: 1.5);

    return ThemeData(
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(borderSide: enabled),
        focusedBorder: OutlineInputBorder(borderSide: focused),
        isDense: true,
      ),
    );
  }
}

abstract class SurveyBuilder<Q extends SurveyQuestion> {
  /// If we remove this constructor, the subclasses get mad :(
  const SurveyBuilder();

  factory SurveyBuilder.fromRecord(SurveyRecord record) => switch (record.question) {
        YesNoQuestion() => _YesNo(),
        TextPromptQuestion() => _TextPrompt(),
        CheckboxQuestion() => _Checkbox(),
        RadioQuestion() => _Radio(),
        ScaleQuestion() => _Scale(),
      } as SurveyBuilder<Q>;

  Widget fieldLayout(BuildContext context, Widget question, Widget answer) {
    return Column(children: [question, answer, const SizedBox(height: 20)]);
  }

  Widget buildAnswer(BuildContext context, ValueChanged update, Q question, _);
}

class _YesNo extends SurveyBuilder<YesNoQuestion> {
  @override
  Widget fieldLayout(context, question, answer) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: question),
        Padding(padding: const EdgeInsets.all(20), child: answer),
      ],
    );
  }

  @override
  Widget buildAnswer(context, update, question, covariant bool? saidYes) {
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
  Widget buildAnswer(context, update, question, covariant int? index) {
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
            title: TextField(
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
  Widget buildAnswer(context, update, question, covariant List<bool> checks) {
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
            title: TextField(
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
  Widget buildAnswer(context, update, question, covariant int value) {
    final divisions = question.values.length - 1;
    return LayoutBuilder(builder: (context, constraints) {
      final sliderWidth = constraints.maxWidth - 100;
      final labelOffset = Offset(sliderWidth / 2 - 25, 0);
      final colors = context.colorScheme;
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
                  style: context.theme.textTheme.labelMedium,
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
            child: Text(question.values[value], style: context.theme.textTheme.labelLarge),
          ),
        ],
      );
    });
  }
}
