import 'package:flutter/material.dart';
import 'package:thc/models/navigation.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/survey/survey_field.dart';
import 'package:thc/views/survey/survey_questions.dart';
import 'package:thc/views/survey/survey_screen.dart';
import 'package:thc/views/survey/survey_theme.dart';

/// This is meant for demonstration; the survey isn't saved to Firebase or local storage.
List<SurveyQuestion> customSurvey = [];

extension ValidQuestion on List<String> {
  /// Returns `true` if the item at this [index] is a valid option
  /// for a scale or multiple-choice question.
  ///
  /// The item should be non-empty and should be unique from items before it.
  bool validChoice(int index, [String? choice]) {
    choice ??= this[index];
    return choice.valid && !sublist(0, index).contains(choice);
  }

  /// Returns true if every option is a valid choice.
  bool get valid => indexed.every((item) => validChoice(item.$1, item.$2));

  /// Iterates through the list, removing invalid choices.
  void validate() {
    for (int index = length - 1; index >= 0; index--) {
      if (!validChoice(index)) removeAt(index);
    }
  }
}

class ViewCustomSurvey extends StatelessWidget {
  const ViewCustomSurvey({super.key});

  @override
  Widget build(BuildContext context) {
    if (customSurvey.isNotEmpty) return SurveyScreen(questions: customSurvey);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '(survey not created yet)',
              style: context.theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 25),
            FilledButton(
              onPressed: () => navigator.pushReplacement(const SurveyEditor()),
              child: const Text('create survey'),
            ),
          ],
        ),
      ),
    );
  }
}

class SurveyEditor extends StatelessWidget {
  const SurveyEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.lightDark(
        SurveyColors.orangeWhite,
        SurveyColors.maroonSunset,
      ),
      body: Center(
        child: ReorderableListView(
          children: [
            for (final question in customSurvey) SurveyFieldEditor(SurveyRecord.init(question)),
          ],
          onReorder: (_, __) => {},
        ),
      ),
    );
  }
}

class SurveyFieldEditor extends StatelessWidget {
  const SurveyFieldEditor(this.record, {super.key});
  final SurveyRecord record;

  @override
  Widget build(BuildContext context) {
    return SurveyField(record, (value) {});
  }
}
