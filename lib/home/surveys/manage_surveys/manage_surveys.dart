import 'package:flutter/material.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/home/surveys/edit_survey/survey_editor.dart';
import 'package:thc/home/surveys/manage_surveys/survey_responses.dart';
import 'package:thc/home/surveys/take_survey/survey.dart';
import 'package:thc/home/surveys/take_survey/survey_theme.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/theme.dart';

class ManageSurveys extends StatelessWidget {
  const ManageSurveys({super.key});

  @override
  Widget build(BuildContext context) {
    final responseSummary = Theme(
      data: SurveyTheme.of(context),
      child: Builder(
        builder: (context) => FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: ThcColors.of(context).surfaceContainerHighest,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 33),
          ),
          onPressed: () => navigator.push(const SurveyResponseScreen()),
          child: const Text('survey response summary'),
        ),
      ),
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [responseSummary, const CustomSurveyButtons()],
      ),
    );
  }
}

class CustomSurveyButtons extends StatefulWidget {
  const CustomSurveyButtons({super.key});

  @override
  State<CustomSurveyButtons> createState() => _CustomSurveyButtonsState();
}

class _CustomSurveyButtonsState extends State<CustomSurveyButtons> {
  ThcSurvey surveyType = ThcSurvey.introSurvey;
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ThcColors.dullBlue.withAlpha(0x40),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton(
              focusColor: Colors.transparent,
              value: surveyType,
              items: [
                for (final type in ThcSurvey.values)
                  DropdownMenuItem(value: type, child: Text('  $type'))
              ],
              onChanged: (newType) => setState(() => surveyType = newType!),
            ),
            const SizedBox(width: 25),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final questions = await surveyType.getQuestions();
                    return navigator.push(SurveyScreen(questions, surveyType: surveyType));
                  },
                  child: const Text('view'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final questions = await surveyType.getQuestions();
                    navigator.push(SurveyEditor(surveyType, questions));
                  },
                  child: const Text('edit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
