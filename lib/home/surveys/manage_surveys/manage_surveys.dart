import 'package:flutter/material.dart';
import 'package:thc/home/surveys/edit_survey/survey_editor.dart';
import 'package:thc/home/surveys/manage_surveys/survey_responses.dart';
import 'package:thc/home/surveys/take_survey/survey_theme.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/theme.dart';

class ManageSurveys extends StatelessWidget {
  const ManageSurveys({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: SurveyColors.orangeSunset),
            onPressed: () => navigator.push(const SurveyResponseScreen()),
            child: const Text('survey response summary', style: TextStyle(height: 5)),
          ),
          const CustomSurveyButtons(),
        ],
      ),
    );
  }
}

class CustomSurveyButtons extends StatelessWidget {
  const CustomSurveyButtons({super.key});

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
            const Text(
              'custom survey',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 25),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => navigator.push(const ViewCustomSurvey()),
                  child: const Text('view'),
                ),
                ElevatedButton(
                  onPressed: () => navigator.push(const SurveyEditor()),
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
