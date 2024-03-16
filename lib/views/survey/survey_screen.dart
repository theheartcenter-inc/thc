import 'package:flutter/material.dart';

@immutable
sealed class SurveyQuestion {
  String get description;
}

class YesNo implements SurveyQuestion {
  YesNo({required this.description});
  @override
  final String description;
}

class MultipleChoice implements SurveyQuestion {
  MultipleChoice({required this.description, required this.choices});
  @override
  final String description;
  final List<String> choices;
}

class Checkboxes implements SurveyQuestion {
  Checkboxes({required this.description, required this.choices});
  @override
  final String description;
  final List<String> choices;
}

class Scale implements SurveyQuestion {
  Scale({required this.description, required this.values});
  @override
  final String description;
  final List<String> values;
}

class TextResponse implements SurveyQuestion {
  TextResponse({required this.description});
  @override
  final String description;
}
