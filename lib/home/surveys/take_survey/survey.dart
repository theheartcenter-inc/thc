import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/home/surveys/survey_questions.dart';
import 'package:thc/home/surveys/take_survey/survey_field.dart';
import 'package:thc/home/surveys/take_survey/survey_theme.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';

/// {@template SurveyScreen}
/// Displays survey questions for the user to answer.
/// {@endtemplate}
class SurveyScreen extends StatefulWidget {
  /// {@macro SurveyScreen}
  const SurveyScreen({super.key, required this.questions});

  /// The list of questions to use.
  ///
  /// Sample lists can be pulled from [SurveyPresets].
  final List<SurveyQuestion> questions;

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

/// {@macro SurveyScreen}
class _SurveyScreenState extends State<SurveyScreen> {
  /// A list of question and answer data.
  late final SurveyData data = SurveyData.fromQuestions(widget.questions);

  /// {@template ValidSurveyAnswers}
  /// When the user taps "submit", it triggers the [ValidSurveyAnswers] cubit.
  ///
  /// Each question that still needs to be answered will be highlighted in a red box.
  /// {@endtemplate}
  ///
  /// If every non-optional question is answered, this will navigate
  /// to a screen that shows results.
  void validate() {
    final validation = context.read<ValidSurveyAnswers>();
    if (data.valid) {
      validation.value = false;
      navigator.pushReplacement(Submitted(data.summary));
      return;
    }
    validation.value = true;
  }

  /// Creates a function for each [SurveyField] that can update the survey [data].
  ValueChanged<dynamic> update(int i, SurveyRecord record) {
    (dynamic, String?) fromMultipleChoice((dynamic, String?) newAnswer) {
      final (oldData, String? oldInput) = record.answer ?? (null, null);
      final (newData, String? newInput) = newAnswer;
      final answer = switch (newInput) {
        String() when newInput.valid => newInput,
        String() => null, // blank answer
        null => oldInput,
      };
      return (newData ?? oldData, answer);
    }

    return (newAnswer) {
      final answer = switch (record.question) {
        MultipleChoice() => fromMultipleChoice(newAnswer),
        _ => newAnswer
      };
      setState(() => data[i] = SurveyRecord(data[i].question, answer));
    };
  }

  @override
  Widget build(BuildContext context) {
    return SurveyTheme(
      surveyContent: Column(
        children: [
          const DarkModeSwitch(),
          const SizedBox(height: 20),
          for (final (i, record) in data.indexed) SurveyField(record, update(i, record)),
          FilledButton(onPressed: validate, child: const Text('Submit')),
          _ValidateMessage(data.invalidCount),
        ],
      ),
    );
  }
}

/// {@template Submitted}
/// Shows a big "thank you" and a summary of the user's answers.
/// {@endtemplate}
class Submitted extends StatelessWidget {
  /// {@macro Submitted}
  const Submitted(this.summary, {super.key});

  /// Whenever you see a weird-looking type, you can hover your mouse on it
  /// for an explanation.
  ///
  /// [QuestionSummary] is just a tuple of strings.
  ///
  /// {@macro ValueChanged}
  final List<QuestionSummary> summary;

  @override
  Widget build(BuildContext context) {
    const thanks = Center(
      child: Text.rich(
        textAlign: TextAlign.center,
        TextSpan(
          children: [
            TextSpan(
              text: 'Thank you!\n',
              style: StyleText(size: 56, letterSpacing: 0.5),
            ),
            TextSpan(
              text: 'your response has been recorded.\n',
              style: StyleText(size: 16, weight: FontWeight.w600),
            ),
            TextSpan(
              text: "(just kidding, it hasn't)\n\n\n",
              style: StyleText(size: 13, letterSpacing: 0.33),
            ),
          ],
        ),
      ),
    );

    final translucent = ThcColors.of(context).onBackground.withOpacity(0.5);

    return Scaffold(
      appBar: AppBar(),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              thanks,
              for (final (question, answer) in summary) ...[
                Text(
                  question,
                  style: const StyleText(size: 16, weight: 600),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 5, 0, 50),
                  child: Text(
                    answer ?? '(no answer)',
                    style: answer == null ? StyleText(color: translucent) : null,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// {@template ValidateMessage}
/// If the user taps "submit" without answering required questions,
/// this widget will display some informative text below the button.
/// {@endtemplate}
class _ValidateMessage extends StatelessWidget {
  /// {@macro ValidateMessage}
  const _ValidateMessage(this.invalidCount);

  /// The number of required questions that haven't been answered.
  final int invalidCount;

  @override
  Widget build(BuildContext context) {
    Widget? child;
    if (context.watch<ValidSurveyAnswers>().value && invalidCount > 0) {
      final theme = Theme.of(context);
      child = Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          invalidCount == 1 ? '1 question left!' : 'answer $invalidCount more questions',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall!.copyWith(color: theme.colorScheme.onErrorContainer),
        ),
      );
    }
    return SizedBox(width: double.infinity, height: 50, child: child);
  }
}

/// {@macro ValidSurveyAnswers}
class ValidSurveyAnswers extends ValueNotifier<bool> {
  /// {@macro ValidSurveyAnswers}
  ValidSurveyAnswers() : super(false);
}
