import 'package:flutter/material.dart';

@immutable
sealed class SurveyQuestion {
  const SurveyQuestion({required this.description});

  final String description;
  dynamic get initial;
}

class YesNoQuestion extends SurveyQuestion {
  const YesNoQuestion({required super.description});
  @override
  bool? get initial => null;
}

class TextPromptQuestion extends SurveyQuestion {
  const TextPromptQuestion({required super.description});
  @override
  String get initial => '';
}

class MultipleChoiceQuestion extends SurveyQuestion {
  const MultipleChoiceQuestion({required super.description, required this.choices});
  final List<String> choices;
  @override
  int? get initial => null;
}

class CheckboxQuestion extends SurveyQuestion {
  const CheckboxQuestion({required super.description, required this.choices});
  final List<String> choices;
  @override
  List<bool> get initial => List.filled(choices.length, false);
}

abstract class ScaleQuestion extends SurveyQuestion {
  const ScaleQuestion({required super.description});

  const factory ScaleQuestion.values({
    required String description,
    required List<String> values,
    bool showEndLabels,
  }) = _NamedValueScale;

  const factory ScaleQuestion.endpoints({
    required String description,
    required (String, String) endpoints,
  }) = _NamedEndpointScale;

  (String, String)? get endpoints;
  String? operator [](int index);
  int get length;
  @override
  int get initial => 0;
}

class _NamedValueScale extends ScaleQuestion {
  const _NamedValueScale({
    required super.description,
    required List<String> values,
    this.showEndLabels = true,
  }) : _values = values;

  final List<String> _values;
  final bool showEndLabels;

  @override
  (String, String)? get endpoints => showEndLabels ? (_values.first, _values.last) : null;
  @override
  int get length => _values.length;
  @override
  String operator [](int index) => _values[index];
}

class _NamedEndpointScale extends ScaleQuestion {
  const _NamedEndpointScale({
    required super.description,
    required this.endpoints,
  });

  @override
  final (String, String) endpoints;

  @override
  final length = 5;
  @override
  String? operator [](_) => null;
}
