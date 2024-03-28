import 'package:flutter/material.dart';
import 'package:thc/views/survey/survey_theme.dart';
import 'package:thc/views/widgets.dart';

class ManageSurveys extends StatelessWidget {
  const ManageSurveys({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: FunPlaceholder(
        'edit surveys,\nview survey response summary',
        color: SurveyColors.orangeSunset,
      ),
    );
  }
}
