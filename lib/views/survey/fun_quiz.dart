/// {@template totally_not_a_waste_of_time}
/// The cynical/critical folks may argue that this was a waste of time.
///
/// But this quiz is undoubtedly a fantastic way to showcase how our survey format
/// can be utilized and possibly expanded upon in the future.
/// {@endtemplate}
///
/// (The [FunQuiz] class resides in `survey_questions.dart`)
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:thc/models/navigator.dart';
import 'package:thc/views/survey/survey_questions.dart';
import 'package:thc/views/widgets.dart';

/// {@macro totally_not_a_waste_of_time}
class FunQuizResults extends StatelessWidget {
  /// {@macro totally_not_a_waste_of_time}
  const FunQuizResults(this.answers, {super.key});
  final List<int> answers;

  @override
  Widget build(BuildContext context) {
    const semiBold = TextStyle(fontWeight: FontWeight.w600);

    final preferences = answers.toList();
    final userHeight = preferences.removeLast();
    int distance = 0;
    int maxDistance = 0;

    int diff(int a, int b) => (a - b).abs();
    void computeNateDistance(int value, int nateValue, [int maxValue = 4]) {
      distance += diff(value, nateValue);
      maxDistance += max(diff(nateValue, 0), diff(nateValue, maxValue));
    }

    for (final (i, userValue) in preferences.indexed) {
      computeNateDistance(userValue, FunQuiz.myAnswers[i]);
    }
    computeNateDistance(userHeight, FunQuiz.myAnswers.last, FunQuiz.heights.length - 1);

    final natePercent = (1 - distance / maxDistance) * 100;

    return Scaffold(
      body: SizedBox.expand(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              for (final (i, answer) in preferences.indexed) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    SurveyPresets.funQuiz.questions[i + 1].description,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 2),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text.rich(TextSpan(children: [
                        const TextSpan(text: 'you picked: ', style: semiBold),
                        TextSpan(text: FunQuiz.scaleValues[answer]),
                      ])),
                    ),
                    Expanded(
                      child: Text.rich(TextSpan(children: [
                        const TextSpan(text: 'Nate picked: ', style: semiBold),
                        TextSpan(text: FunQuiz.scaleValues[FunQuiz.myAnswers[i]]),
                      ])),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                for (final flex in [answer, FunQuiz.myAnswers[i]]) FunQuizChart(flex, 4),
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
                          const TextSpan(text: 'your height: ', style: semiBold),
                          TextSpan(text: FunQuiz.heights[userHeight]),
                        ]),
                      ),
                    ),
                    const Expanded(
                      child: Text.rich(
                        style: TextStyle(fontSize: 18),
                        TextSpan(children: [
                          TextSpan(text: "Nate's height: ", style: semiBold),
                          TextSpan(text: "5'5"),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
              for (final flex in [userHeight, FunQuiz.myAnswers.last])
                FunQuizChart(flex, FunQuiz.heights.length - 1),
              const SizedBox(height: 100),
              Text.rich(
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
                TextSpan(children: [
                  const TextSpan(text: 'overall:   '),
                  TextSpan(
                    text: '${natePercent.toStringAsFixed(1)}%\n',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 32, height: 3),
                  ),
                  TextSpan(
                    text: switch (natePercent) {
                      0 => "Honestly, I'm impressed.",
                      < 50 => "It's a good thing this isn't a grade!",
                      < 75 => 'Solid mix of similarity & diversity 👍',
                      < 90 => 'Dang… we got a lot in common!',
                      < 100 => '…soul mates?',
                      _ => 'Hello, me.',
                    },
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ]),
              ),
              const SizedBox(height: 125),
              FilledButton(
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
              const SizedBox(height: 75),
            ],
          ),
        ),
      ),
    );
  }
}

/// {@macro totally_not_a_waste_of_time}
class FunQuizChart extends StatefulWidget {
  /// {@macro totally_not_a_waste_of_time}
  const FunQuizChart(this.flex, this.maxFlex, {super.key});
  final int flex, maxFlex;

  @override
  State<FunQuizChart> createState() => _FunQuizChartState();
}

/// {@macro totally_not_a_waste_of_time}
class _FunQuizChartState extends StateAsync<FunQuizChart> {
  bool expanded = false;

  @override
  void animate() => sleepState(0.6, () => expanded = true);

  @override
  Widget build(BuildContext context) {
    final flex = widget.flex / widget.maxFlex;
    final hsl = HSLColor.fromAHSL(1, flex * 180, (flex - 0.5).abs() * 1.5 + 0.25, 0.5);
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
              color: hsl.toColor(),
              child: const SizedBox.expand(),
            );
          }),
        ),
      ),
    );
  }
}
