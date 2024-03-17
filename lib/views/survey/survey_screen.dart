import 'package:flutter/material.dart';
import 'package:thc/views/survey/survey_classes.dart';

const introQuestions = [
  (SurveyQuestion.yesNo(description: 'Are you in need of meditation?'), YesNoAnswer(true)),
  (
    SurveyQuestion.yesNo(
      description: 'Are you a person impacted by incarceration directly '
          'and through a loved one or survivors too, including CDCR officers, '
          'and folx who are doing the work to end mass incarceration?',
    ),
    YesNoAnswer(true),
  ),
];

const sampleStreamQuestions = [
  (
    SurveyQuestion.yesNo(description: 'Did you find this practice helpful?'),
    YesNoAnswer(true),
  ),
  (
    SurveyQuestion.scale(
      description: 'How are you feeling right now?',
      values: ['awful', 'not good', 'neutral', 'good', 'fantastic'],
    ),
    ScaleAnswer(),
  ),
  (
    SurveyQuestion.multipleChoice(
      description: "What's your favorite color?",
      choices: ['red', 'yellow', 'green', 'cyan', 'blue', 'magenta'],
    ),
    MultipleChoiceAnswer(3),
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

class SurveyScreen extends StatelessWidget {
  const SurveyScreen({super.key, required this.questions});
  final List<(SurveyQuestion, SurveyAnswer)> questions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (question, answer) in questions)
                SurveyWidget(question: question, answer: answer, onUpdate: (_) {}),
              FilledButton(onPressed: () {}, child: const Text('Submit')),
            ],
          ),
        ),
      ),
    );
  }
}

class SurveyWidget<Q extends SurveyQuestion, A extends SurveyAnswer> extends StatelessWidget {
  const SurveyWidget({
    super.key,
    required this.question,
    required this.answer,
    required this.onUpdate,
  });
  final Q question;
  final A? answer;
  final void Function(A answer) onUpdate;

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
          segments: const [
            ButtonSegment(value: true, label: Text('yes')),
            ButtonSegment(value: false, label: Text('no')),
          ],
          selected: {if (answer case final YesNoAnswer response) response.saidYes},
          onSelectionChanged: (answer) => onUpdate(YesNoAnswer(answer.first) as A),
        );
      case TextPromptQuestion():
        answerGraphic = TextField(onChanged: (value) => onUpdate(TextPromptAnswer(value) as A));

      case final MultipleChoiceQuestion q:
        final response = answer as MultipleChoiceAnswer?;
        answerGraphic = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, choice) in q.choices.indexed)
              RadioListTile(
                title: Text(choice),
                value: i,
                groupValue: response?.selected,
                onChanged: (newIndex) => onUpdate(MultipleChoiceAnswer(newIndex!) as A),
              ),
          ],
        );
      case final CheckboxQuestion q:
        final response = answer as CheckboxAnswer;
        answerGraphic = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, choice) in q.choices.indexed)
              CheckboxListTile(
                title: Text(choice),
                value: response.selected[i],
                onChanged: (checked) {
                  final selected = response.selected.toList();
                  selected[i] = !selected[i];
                  onUpdate(CheckboxAnswer(selected) as A);
                },
              ),
          ],
        );
      case final ScaleQuestion q:
        final response = answer as ScaleAnswer;
        answerGraphic = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider.adaptive(
              value: response.value.toDouble(),
              onChanged: (newValue) => onUpdate(ScaleAnswer(newValue.round()) as A),
            ),
            Text(q.values[response.value]),
          ],
        );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [questionText, answerGraphic, const SizedBox(height: 50)],
    );
  }
}
