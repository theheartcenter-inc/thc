import 'package:flutter/material.dart';
import 'package:thc/home/surveys/take_survey/survey_theme.dart';
import 'package:thc/utils/widgets/fun_placeholder.dart';

class ManageSurveys extends StatelessWidget {
  const ManageSurveys({super.key});

  @override
  Widget build(BuildContext context) {
    return const FunPlaceholder(
      'edit surveys,\nview survey response summary',
      color: SurveyColors.orangeSunset,
    );
  }
}
