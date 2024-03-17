import 'package:flutter/material.dart';

@immutable
sealed class SurveyQuestion {
  const SurveyQuestion();

  const factory SurveyQuestion.yesNo({required String description}) = YesNoQuestion;

  const factory SurveyQuestion.textPrompt({required String description}) = TextPromptQuestion;

  const factory SurveyQuestion.multipleChoice({
    required String description,
    required List<String> choices,
  }) = MultipleChoiceQuestion;

  const factory SurveyQuestion.checkboxes({
    required String description,
    required List<String> choices,
  }) = CheckboxQuestion;

  const factory SurveyQuestion.scale({
    required String description,
    required List<String> values,
  }) = ScaleQuestion;

  String get description;
}

@immutable
sealed class SurveyAnswer {
  const SurveyAnswer();
}

class YesNoQuestion extends SurveyQuestion {
  const YesNoQuestion({required this.description});
  @override
  final String description;
}

class YesNoAnswer extends SurveyAnswer {
  const YesNoAnswer(this.saidYes);
  final bool saidYes;
}

class TextPromptQuestion extends SurveyQuestion {
  const TextPromptQuestion({required this.description});
  @override
  final String description;
}

class TextPromptAnswer extends SurveyAnswer {
  const TextPromptAnswer([this.text = '']);
  final String text;
}

class MultipleChoiceQuestion extends SurveyQuestion {
  const MultipleChoiceQuestion({required this.description, required this.choices});
  @override
  final String description;
  final List<String> choices;
}

class MultipleChoiceAnswer extends SurveyAnswer {
  const MultipleChoiceAnswer(this.selected);
  final int selected;
}

class CheckboxQuestion extends SurveyQuestion {
  const CheckboxQuestion({required this.description, required this.choices});
  @override
  final String description;
  final List<String> choices;
}

class CheckboxAnswer extends SurveyAnswer {
  const CheckboxAnswer(this.selected);
  CheckboxAnswer.initial(int answerCount) : selected = List.filled(answerCount, false);
  final List<bool> selected;
}

class ScaleQuestion extends SurveyQuestion {
  const ScaleQuestion({required this.description, required this.values});
  @override
  final String description;
  final List<String> values;
}

class ScaleAnswer extends SurveyAnswer {
  const ScaleAnswer([this.value = 0]);
  final int value;
}
