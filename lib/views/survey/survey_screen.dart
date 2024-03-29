import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/models/bloc.dart';
import 'package:thc/models/navigator.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/survey/fun_quiz.dart';
import 'package:thc/views/survey/survey_field.dart';
import 'package:thc/views/survey/survey_questions.dart';
import 'package:thc/views/survey/survey_theme.dart';

/// {@template views.survey.SurveyScreen}
/// Displays survey questions for the user to answer.
/// {@endtemplate}
class SurveyScreen extends StatefulWidget {
  /// {@macro views.survey.SurveyScreen}
  const SurveyScreen({super.key, required this.questions});

  /// The list of questions to use.
  ///
  /// Sample lists can be pulled from [SurveyPresets].
  final List<SurveyQuestion> questions;

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

/// {@macro views.survey.SurveyScreen}
class _SurveyScreenState extends State<SurveyScreen> {
  /// A list of question and answer data.
  late final SurveyData data = SurveyData.fromQuestions(widget.questions);

  /// {@template views.survey.SurveyValidation}
  /// When the user taps "submit", it triggers the [SurveyValidation] cubit.
  ///
  /// Each question that still needs to be answered will be highlighted in a red box.
  /// {@endtemplate}
  ///
  /// If every non-optional question is answered, this will navigate
  /// to a screen that shows results.
  void validate() {
    if (FunQuiz.inProgress) {
      navigator.pushReplacement(FunQuizResults(data.funQuizResults));
      return;
    } else if (data.valid) {
      navigator.pushReplacement(Submitted(data.summary));
      return;
    }
    context.read<SurveyValidation>().submit();
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
    return SurveyStyling(
      child: Column(
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

/// {@template views.survey.Submitted}
/// Shows a big "thank you" and a summary of the user's answers.
/// {@endtemplate}
class Submitted extends StatelessWidget {
  /// {@macro views.survey.Submitted}
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
              style: TextStyle(fontSize: 56, letterSpacing: 0.5),
            ),
            TextSpan(
              text: 'your response has been recorded.\n',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: "(just kidding, it hasn't)\n\n\n",
              style: TextStyle(fontSize: 13, letterSpacing: 0.33),
            ),
          ],
        ),
      ),
    );

    final translucent = context.colorScheme.onBackground.withOpacity(0.5);

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
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 5, 0, 50),
                  child: Text(
                    answer ?? '(no answer)',
                    style: answer == null ? TextStyle(color: translucent) : null,
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

/// {@template views.survey.ValidateMessage}
/// If the user taps "submit" without answering required questions,
/// this widget will display some informative text below the button.
/// {@endtemplate}
class _ValidateMessage extends StatelessWidget {
  /// {@macro views.survey.ValidateMessage}
  const _ValidateMessage(this.invalidCount);

  /// The number of required questions that haven't been answered.
  final int invalidCount;

  @override
  Widget build(BuildContext context) {
    Widget? child;
    if (context.watch<SurveyValidation>().state && invalidCount > 0) {
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

/// {@macro views.survey.SurveyValidation}
class SurveyValidation extends Cubit<bool> {
  /// {@macro views.survey.SurveyValidation}
  SurveyValidation() : super(false);

  /// {@macro views.survey.SurveyValidation}
  void submit() => state ? null : emit(true);
}
