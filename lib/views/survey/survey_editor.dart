import 'dart:io';

import 'package:flutter/material.dart';
import 'package:thc/models/bloc.dart';
import 'package:thc/models/navigation.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/survey/survey_field.dart';
import 'package:thc/views/survey/survey_questions.dart';
import 'package:thc/views/survey/survey_screen.dart';

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
      appBar: AppBar(),
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

class SurveyEditor extends StatefulWidget {
  const SurveyEditor({super.key});

  @override
  State<SurveyEditor> createState() => _SurveyEditorState();
}

class _SurveyEditorState extends State<SurveyEditor> {
  final questions = customSurvey.toList();
  void Function(SurveyQuestion) addQuestion(int index) =>
      (question) => setState(() => questions.insert(index, question));

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SurveyValidation(),
      child: Builder(
        builder: (context) {
          final questionNames = [for (final q in questions) q.description];
          final editors = [
            for (final (i, question) in questions.indexed) ...[
              SurveyFieldEditor(
                key: Key(
                  questionNames.validChoice(i)
                      ? question.description
                      : '${question.runtimeType} with invalid name, index $i',
                ),
                divider: SurveyEditDivider(addQuestion(i)),
                record: SurveyRecord.init(question),
              ),
            ],
            SurveyEditDivider(
              key: const Key('end divider'),
              addQuestion(questions.length),
            ),
          ];
          return Scaffold(
            appBar: AppBar(title: const Text('Survey Editor')),
            body: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              behavior: HitTestBehavior.translucent,
              child: Center(
                child: ReorderableListView(
                  shrinkWrap: true,
                  buildDefaultDragHandles: false,
                  onReorder: (_, __) => {},
                  children: editors,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SurveyFieldEditor extends StatelessWidget {
  const SurveyFieldEditor({required this.divider, required this.record, super.key});
  final SurveyEditDivider divider;
  final SurveyRecord record;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(children: [divider, SurveyField(record, (value) {})]),
        InkWell(
          // use Positioned :)
          onTap: () {},
          child: const ColoredBox(color: Colors.amber),
        ),
      ],
    );
  }
}

class SurveyEditDivider extends StatefulWidget {
  const SurveyEditDivider(this.addQuestion, {super.key});
  final void Function(SurveyQuestion) addQuestion;

  @override
  State<SurveyEditDivider> createState() => _SurveyEditDividerState();
}

class _SurveyEditDividerState extends State<SurveyEditDivider> {
  final node = FocusNode();
  bool hovered = false, focused = false;
  static final isMobile =
      switch (Platform.operatingSystem) { 'ios' || 'android' => true, _ => false };

  @override
  void initState() {
    super.initState();
    node.addListener(() => setState(() => focused = node.hasPrimaryFocus));
  }

  static const presets = [
    YesNoQuestion('[question]'),
    TextPromptQuestion('[question]'),
    RadioQuestion('[question]', choices: ['choice']),
    CheckboxQuestion('[question]', choices: ['choice']),
    ScaleQuestion('[question]'),
  ];

  @override
  Widget build(BuildContext context) {
    final Widget button;
    if (focused) {
      button = Focus(
        focusNode: node,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final question in presets) ...[
              InkWell(
                onTap: () {
                  widget.addQuestion(question);
                  node.unfocus();
                },
                child: QuestionTypeIcon(question),
              ),
            ],
          ],
        ),
      );
    } else {
      button = InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        focusNode: node,
        onTap: node.requestFocus,
        child: Padding(
          padding: EdgeInsets.all(hovered ? 8 : 2),
          child: Opacity(opacity: hovered ? 1 : 0.5, child: const Icon(Icons.add)),
        ),
      );
    }

    final lineColor = context.colorScheme.onBackground.withOpacity(0.125);

    final bool expanded = isMobile || hovered || focused;

    final child = SizedBox(
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Divider(color: lineColor),
          Card(
            clipBehavior: Clip.antiAlias,
            color: expanded ? null : context.colorScheme.background,
            elevation: expanded ? null : 0,
            child: AnimatedSize(
              duration: Durations.medium1,
              curve: Curves.ease,
              child: button,
            ),
          ),
        ],
      ),
    );

    if (isMobile) return child;

    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: child,
    );
  }
}

class QuestionTypeIcon extends StatelessWidget {
  const QuestionTypeIcon(this.question, {super.key});
  final SurveyQuestion question;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final foregroundColor = colors.onSurface;
    final backgroundColor = colors.surface;
    final Widget graphic;
    switch (question) {
      case YesNoQuestion():
        graphic = DecoratedBox(
          decoration: BoxDecoration(
            color: foregroundColor.withAlpha(0x80),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 3, 3.5, 3),
                child: Icon(Icons.check, color: backgroundColor),
              ),
              ColoredBox(
                color: backgroundColor,
                child: const SizedBox(width: 1, height: 20),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(3, 3, 5, 3),
                child: Icon(Icons.close, color: backgroundColor),
              ),
            ],
          ),
        );
      case TextPromptQuestion():
        graphic = DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: foregroundColor),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 3),
            child: Text(
              'text',
              style: TextStyle(fontSize: 12, color: foregroundColor.withAlpha(0xcc)),
            ),
          ),
        );
      case final MultipleChoice q:
        final (IconData selected, IconData unselected) = switch (q) {
          RadioQuestion() => (Icons.radio_button_checked, Icons.radio_button_off),
          CheckboxQuestion() => (Icons.check_box, Icons.check_box_outline_blank),
        };
        graphic = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(unselected), Icon(unselected), Icon(selected)],
          ),
        );
      case ScaleQuestion():
        graphic = Stack(
          alignment: const Alignment(-0.33, 0),
          children: [
            for (final size in const [Size(40, 4), Size(12, 12)])
              SizedBox.fromSize(
                size: size,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: foregroundColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: switch (colors.brightness) {
                      Brightness.light => null,
                      Brightness.dark => const [BoxShadow(blurRadius: 1)],
                    },
                  ),
                ),
              ),
          ],
        );
    }
    return Theme(
      data: context.theme.copyWith(
        iconTheme: IconThemeData(size: 12, color: foregroundColor),
      ),
      child: SizedBox(
        height: 50,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: question is ScaleQuestion
                ? null
                : Border(right: BorderSide(color: foregroundColor.withOpacity(0.25))),
          ),
          child: Align(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: graphic,
            ),
          ),
        ),
      ),
    );
  }
}
