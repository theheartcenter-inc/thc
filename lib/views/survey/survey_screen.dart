import 'dart:math';

import 'package:flutter/material.dart';
import 'package:thc/models/navigator.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/survey/survey_questions.dart';
import 'package:thc/views/survey/survey_theme.dart';
import 'package:thc/views/widgets.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key, required this.questions});
  final List<SurveyQuestion> questions;

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  late final List<dynamic> answers;
  late final int count;
  late List<bool> valid;
  bool get isValid => !valid.contains(false);
  int get invalidCount => valid.fold(0, (total, item) => total += (item ? 0 : 1));
  void validate() {
    if (FunQuiz.inProgress) {
      navigator.pushReplacement(_FunQuizResults((answers..removeAt(0)).cast()));
      return;
    }
    final data = SurveyData.fromLists(widget.questions, answers);
    setState(() => valid = data.validation);

    if (isValid) {
      navigator.pushReplacement(Submitted(summary: data.surveySummary));
    }
  }

  @override
  void initState() {
    super.initState();
    answers = [for (final question in widget.questions) question.initial];
    count = answers.length;
    valid = List.filled(count, true);
  }

  @override
  Widget build(BuildContext context) {
    return SurveyStyling([
      const Padding(padding: EdgeInsets.only(bottom: 20), child: DarkModeSwitch()),
      for (final (i, question) in widget.questions.indexed)
        SurveyWidget(
          question: question,
          answer: answers[i],
          valid: valid[i],
          onUpdate: (newAnswer) {
            dynamic currentAnswer;
            if (question is MultipleChoice) {
              final (oldData, String? oldInput) = answers[i] ?? (null, null);
              final (newData, String? newInput) = newAnswer;
              currentAnswer = (newData ?? oldData, newInput.validated ?? oldInput);
            }
            currentAnswer ??= newAnswer;
            setState(() {
              answers[i] = currentAnswer;
              if (!valid[i]) valid[i] = SurveyRecord(question, currentAnswer).valid;
            });
          },
        ),
      FilledButton(
        onPressed: validate,
        child: const Text('Submit'),
      ),
      const SizedBox(height: 8),
      ValidateMessage(invalidCount),
    ]);
  }
}

class Submitted extends StatelessWidget {
  const Submitted({super.key, required this.summary});
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
              text: "(just kidding it hasn't)\n\n\n",
              style: TextStyle(fontSize: 13, letterSpacing: 0.33),
            ),
          ],
        ),
      ),
    );

    final translucent = context.colorScheme.onBackground.withOpacity(0.5);
    final formatted = [
      for (final (question, answer) in summary) ...[
        Text(
          question,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 5, 0, 50),
          child: Text(
            answer ?? '(no answer)',
            style: TextStyle(color: answer == null ? translucent : null),
          ),
        ),
      ]
    ];

    return Scaffold(
      appBar: AppBar(),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [thanks, ...formatted],
            ),
          ),
        ),
      ),
    );
  }
}

class _FunQuizResults extends StatelessWidget {
  const _FunQuizResults(this.answers);
  final List<int> answers;

  static double computeNatePercent(int userValue, int nateValue, [int maxValue = 4]) {
    int diff(int a, int b) => (a - b).abs();
    final distance = diff(userValue, nateValue);
    final maxDistance = max(diff(nateValue, 0), diff(nateValue, maxValue));
    return 1 - distance / maxDistance;
  }

  @override
  Widget build(BuildContext context) {
    final preferences = answers.toList();
    final userHeight = preferences.removeLast();

    double natePercentSum = 0;
    for (final (i, userValue) in preferences.indexed) {
      natePercentSum += computeNatePercent(userValue, FunQuiz.myAnswers[i]);
    }
    natePercentSum += computeNatePercent(
      userHeight,
      FunQuiz.myAnswers.last,
      FunQuiz.heights.length - 1,
    );
    final overallNatePercent = natePercentSum / FunQuiz.myAnswers.length;

    return Scaffold(
      body: SizedBox.expand(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (i, answer) in preferences.indexed) ...[
                  Text(
                    SurveyPresets.funQuiz.questions[i + 1].description,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 2),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text.rich(TextSpan(children: [
                          const TextSpan(
                            text: 'you picked: ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: FunQuiz.scaleValues[answer]),
                        ])),
                      ),
                      Expanded(
                        child: Text.rich(TextSpan(children: [
                          const TextSpan(
                            text: 'Nate picked: ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: FunQuiz.scaleValues[FunQuiz.myAnswers[i]]),
                        ])),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  for (final flex in [answer, FunQuiz.myAnswers[i]]) _FunQuizChart(flex, 4),
                  const SizedBox(height: 30),
                ],
                Padding(
                  padding: const EdgeInsets.only(top: 50, bottom: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          style: const TextStyle(fontSize: 18),
                          TextSpan(children: [
                            const TextSpan(
                              text: 'your height: ',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(text: FunQuiz.heights[userHeight]),
                          ]),
                        ),
                      ),
                      const Expanded(
                        child: Text.rich(
                          style: TextStyle(fontSize: 18),
                          TextSpan(children: [
                            TextSpan(
                              text: "Nate's height: ",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(text: "5'5"),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
                for (final flex in [userHeight, FunQuiz.myAnswers.last])
                  _FunQuizChart(flex, FunQuiz.heights.length - 1),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 100),
                    child: Text.rich(
                      style: const TextStyle(fontSize: 18),
                      TextSpan(children: [
                        const TextSpan(text: 'your "Nate%":  '),
                        TextSpan(
                          text: ' ${(overallNatePercent * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 32),
                        ),
                      ]),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xff00ffff),
                        foregroundColor: Colors.black,
                        shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                      ),
                      onPressed: () {
                        FunQuiz.inProgress = false;
                        navigator.pop();
                      },
                      child: const Text(
                        'Done',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FunQuizChart extends StatefulWidget {
  const _FunQuizChart(this.flex, this.maxFlex);
  final int flex, maxFlex;

  @override
  State<_FunQuizChart> createState() => _FunQuizChartState();
}

class _FunQuizChartState extends StateAsync<_FunQuizChart> {
  @override
  void animate() => sleepState(0.6, () => expanded = true);

  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final flex = widget.flex / widget.maxFlex;
    final color = Color.lerp(
      const Color(0xff800000),
      const Color(0xff00ffff),
      expanded ? flex : 0,
    );
    const buffer = 10.0;
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: SizedBox(
        height: 20,
        child: Align(
          alignment: Alignment.centerLeft,
          child: LayoutBuilder(builder: (context, constraints) {
            return AnimatedContainer(
              duration: Durations.extralong4,
              curve: Curves.ease,
              width: expanded ? flex * (constraints.maxWidth - buffer) + buffer : 0,
              color: color,
              child: const SizedBox.expand(),
            );
          }),
        ),
      ),
    );
  }
}

class ValidateMessage extends StatelessWidget {
  const ValidateMessage(this.invalidCount, {super.key});
  final int invalidCount;

  @override
  Widget build(BuildContext context) {
    Widget? child;
    if (invalidCount > 0) {
      final theme = Theme.of(context);
      child = Text(
        invalidCount == 1 ? '1 question left!' : 'answer $invalidCount more questions',
        textAlign: TextAlign.center,
        style: theme.textTheme.labelSmall!.copyWith(color: theme.colorScheme.onErrorContainer),
      );
    }

    return SizedBox(width: double.infinity, height: 50, child: child);
  }
}

class SurveyWidget extends StatelessWidget {
  const SurveyWidget({
    super.key,
    required this.question,
    required this.answer,
    required this.valid,
    required this.onUpdate,
  });
  final SurveyQuestion question;
  final dynamic answer;
  final bool valid;
  final ValueChanged<dynamic> onUpdate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final questionText = Padding(
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
            Text(
              question.description,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                shadows: [
                  if (context.theme.brightness == Brightness.dark)
                    Shadow(color: colors.background, blurRadius: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    final textFieldUnderline = InputDecoration(
      enabledBorder: UnderlineInputBorder(
        borderSide: context.theme.inputDecorationTheme.enabledBorder!.borderSide,
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: context.theme.inputDecorationTheme.focusedBorder!.borderSide,
      ),
      isDense: true,
    );

    final Widget answerGraphic;
    Widget? widget;
    switch (question) {
      case YesNoQuestion():
        answerGraphic = SegmentedButton<bool>(
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
          selected: {if (answer case final bool response) response},
          onSelectionChanged: (newAnswer) => onUpdate(newAnswer.firstOrNull ?? answer),
        );
        widget = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: questionText),
            Padding(
              padding: const EdgeInsets.all(20),
              child: answerGraphic,
            ),
          ],
        );
        if (valid) {
          widget = Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: widget,
          );
        }
      case TextPromptQuestion():
        answerGraphic = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(onChanged: onUpdate),
        );

      case final RadioQuestion q:
        final (int? answerIndex, _) = answer ?? (null, null);
        answerGraphic = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, choice) in q.choices.indexed)
              RadioListTile<int>(
                title: Text(choice),
                value: i,
                groupValue: answerIndex,
                onChanged: (newValue) => onUpdate((newValue, null)),
              ),
            if (q.canType)
              RadioListTile<int>(
                title: TextField(
                  decoration: textFieldUnderline,
                  onChanged: (userInput) => onUpdate((null, userInput)),
                  onSubmitted: (userInput) => onUpdate((q.choices.length, userInput)),
                ),
                value: q.choices.length,
                groupValue: answerIndex,
                onChanged: (newValue) => onUpdate((newValue, null)),
              ),
          ],
        );
      case final CheckboxQuestion q:
        final (List<bool> checks, _) = answer;
        void updateSelected(int i, [String? input]) {
          final selected = checks.toList();
          selected[i] = !selected[i];
          onUpdate((selected, input));
        }
        answerGraphic = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, choice) in q.choices.indexed)
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(choice),
                value: checks[i],
                onChanged: (_) => updateSelected(i),
              ),
            if (q.canType)
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                title: TextField(
                  decoration: textFieldUnderline,
                  onChanged: (userInput) => onUpdate((null, userInput)),
                  onSubmitted: (userInput) => updateSelected(q.choices.length, userInput),
                ),
                value: checks[q.choices.length],
                onChanged: (_) => updateSelected(q.choices.length),
              ),
          ],
        );
      case final ScaleQuestion q:
        final value = answer as int;
        final divisions = q.length - 1;
        answerGraphic = LayoutBuilder(builder: (context, constraints) {
          final sliderWidth = constraints.maxWidth - 100;
          final labelOffset = Offset(sliderWidth / 2 - 25, 0);
          final labelStyle = context.theme.textTheme.labelMedium;
          Widget shift(String text, bool isFirst) => Transform.translate(
                offset: labelOffset * (isFirst ? -1 : 1),
                child: Text(text, style: labelStyle),
              );
          final (endpointLabels, endpointHeight) = switch (q.endpoints) {
            final ends? => ([shift(ends.$1, true), shift(ends.$2, false)], 10.0),
            null => (const <Widget>[], 0.0),
          };
          final colors = context.colorScheme;
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              ...endpointLabels,
              Padding(
                padding: EdgeInsets.only(top: endpointHeight),
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
      case MultipleChoice():
        throw StateError('All multiple choice questions are either Radio or Checkbox lists.');
    }
    widget ??= Column(children: [
      questionText,
      answerGraphic,
      SizedBox(height: valid ? 50 : 20),
    ]);
    if (valid) return widget;
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: ColoredBox(color: colors.errorContainer, child: widget),
    );
  }
}
