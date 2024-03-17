import 'package:flutter/material.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/survey/survey_classes.dart';

const introQuestions = [
  YesNoQuestion(description: 'Are you in need of meditation?'),
  YesNoQuestion(
    description: 'Are you a person impacted by incarceration directly '
        'and through a loved one or survivors too, including CDCR officers, '
        'and folx who are doing the work to end mass incarceration?',
  ),
];

const sampleStreamQuestions = <SurveyQuestion>[
  YesNoQuestion(description: 'Did you find this practice helpful?'),
  ScaleQuestion.values(
    description: 'How are you feeling right now?',
    values: ['awful', 'not good', 'neutral', 'good', 'fantastic'],
  ),
  MultipleChoiceQuestion(
    description: "What's your favorite color?",
    choices: ['red', 'yellow', 'green', 'cyan', 'blue', 'magenta'],
  ),
  MultipleChoiceQuestion(
    description: "What's your favorite color?",
    choices: ['red', 'yellow', 'green', 'cyan', 'blue', 'magenta'],
  ),
  MultipleChoiceQuestion(
    description: "What's your favorite color?",
    choices: ['red', 'yellow', 'green', 'cyan', 'blue', 'magenta'],
  ),
];

class IntroSurvey extends StatelessWidget {
  const IntroSurvey({super.key});

  @override
  Widget build(BuildContext context) => const SurveyScreen(questions: introQuestions);
}

class StreamSurvey extends StatelessWidget {
  const StreamSurvey({super.key});

  @override
  Widget build(BuildContext context) => const SurveyScreen(questions: sampleStreamQuestions);
}

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key, required this.questions});
  final List<SurveyQuestion> questions;

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  late final List<dynamic> answers;
  late final int count;

  @override
  void initState() {
    super.initState();
    answers = [for (final question in widget.questions) question.initial];
    count = answers.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xffffb870),
                Color(0xffffffa0),
              ],
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < count; i++)
                  SurveyWidget(
                    question: widget.questions[i],
                    answer: answers[i],
                    onUpdate: (newAnswer) => setState(() => answers[i] = newAnswer),
                  ),
                FilledButton(onPressed: () {}, child: const Text('Submit')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SurveyWidget extends StatelessWidget {
  const SurveyWidget({
    super.key,
    required this.question,
    required this.answer,
    required this.onUpdate,
  });
  final SurveyQuestion question;
  final dynamic answer;
  final ValueChanged<dynamic> onUpdate;

  @override
  Widget build(BuildContext context) {
    final questionText = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          question.description,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
    final Widget answerGraphic;
    switch (question) {
      case YesNoQuestion():
        answerGraphic = SegmentedButton<bool>(
          emptySelectionAllowed: true,
          segments: const [
            ButtonSegment(value: true, label: Text('yes')),
            ButtonSegment(value: false, label: Text('no')),
          ],
          selected: {if (answer case final bool response) response},
          onSelectionChanged: (answer) => onUpdate(answer.first),
        );
      case TextPromptQuestion():
        answerGraphic = TextField(onChanged: onUpdate);

      case final MultipleChoiceQuestion q:
        answerGraphic = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, choice) in q.choices.indexed)
              RadioListTile<int>(
                title: Text(choice),
                value: i,
                groupValue: answer,
                onChanged: onUpdate,
              ),
          ],
        );
      case final CheckboxQuestion q:
        final checks = answer as List<bool>;
        answerGraphic = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, choice) in q.choices.indexed)
              CheckboxListTile(
                title: Text(choice),
                value: checks[i],
                onChanged: (checked) {
                  final selected = checks.toList();
                  selected[i] = !selected[i];
                  onUpdate(selected);
                },
              ),
          ],
        );
      case final ScaleQuestion q:
        final value = answer as int;
        final divisions = q.length - 1;
        answerGraphic = LayoutBuilder(builder: (context, constraints) {
          final sliderWidth = constraints.maxWidth - 120;
          final labelOffset = Offset(sliderWidth / 2 - 24, 0);
          final labelStyle = context.theme.textTheme.labelMedium;
          Widget shift(String text, bool isFirst) => Transform.translate(
                offset: labelOffset * (isFirst ? -1 : 1),
                child: Text(text, style: labelStyle),
              );
          final (endpointLabels, endpointHeight) = switch (q.endpoints) {
            final ends? => ([shift(ends.$1, true), shift(ends.$2, false)], 10.0),
            null => (const <Widget>[], 0.0),
          };
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              ...endpointLabels,
              Padding(
                padding: EdgeInsets.only(top: endpointHeight),
                child: SizedBox(
                  width: sliderWidth,
                  child: Slider.adaptive(
                    divisions: divisions,
                    max: divisions.toDouble(),
                    value: value.toDouble(),
                    onChanged: (newValue) => onUpdate(newValue.round()),
                  ),
                ),
              ),
              if (q[value] case final String text)
                Padding(
                  padding: EdgeInsets.only(top: 45 + endpointHeight),
                  child: Text(text, style: context.theme.textTheme.labelLarge),
                ),
            ],
          );
        });
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [questionText, answerGraphic, const SizedBox(height: 50)],
    );
  }
}
