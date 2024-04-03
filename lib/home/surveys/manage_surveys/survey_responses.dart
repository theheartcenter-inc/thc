import 'package:flutter/material.dart';
import 'package:thc/home/surveys/take_survey/survey_theme.dart';
import 'package:thc/utils/widgets/fun_placeholder.dart';

class SurveyResponseScreen extends StatelessWidget {
  const SurveyResponseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const FunPlaceholder(
        'summary of survey responses',
        color: SurveyColors.orangeSunset,
      ),
    );
  }
}
