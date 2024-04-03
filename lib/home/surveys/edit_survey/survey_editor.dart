import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/home/surveys/edit_survey/survey_field_editor.dart';
import 'package:thc/home/surveys/survey_questions.dart';
import 'package:thc/home/surveys/take_survey/survey.dart';
import 'package:thc/utils/bloc.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/theme.dart';

/// This is meant for demonstration; the survey isn't saved to Firebase or local storage.
List<SurveyQuestion> customSurvey = [];

final isMobile = switch (Platform.operatingSystem) { 'ios' || 'android' => true, _ => false };

extension ValidChoices on List<String> {
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

extension type KeyedQuestion.from((SurveyQuestion, Key) record) {
  KeyedQuestion(SurveyQuestion question) : this.from((question, newKey));

  SurveyQuestion get question => record.$1;
  Key get key => record.$2;
  static Key get newKey => UniqueKey();

  KeyedQuestion copy() => KeyedQuestion.from((question, newKey));
  KeyedQuestion update(SurveyQuestion newQuestion) => KeyedQuestion.from((newQuestion, key));
}

class _SurveyEditorState extends State<SurveyEditor> {
  final questions = [for (final question in customSurvey) KeyedQuestion(question)];
  List<String> get questionNames => [for (final q in questions) q.question.description];

  SurveyEditDivider divider(int index) => SurveyEditDivider(
        (question) => setState(() => questions.insert(index, KeyedQuestion(question))),
      );

  @override
  Widget build(BuildContext context) {
    final editors = [
      for (final (i, q) in questions.indexed)
        SurveyFieldEditor(
          key: q.key,
          index: i,
          question: q.question,
          update: (newValue) => setState(() => questions[i] = questions[i].update(newValue)),
          duplicate: () => setState(() => questions.insert(i + 1, q.copy())),
          yeet: () => setState(() => questions.removeAt(i)),
          validate: () => questionNames.validChoice(i),
          divider: divider(i),
        ),
    ];

    Widget? editButton;
    if (isMobile && questions.isNotEmpty) {
      editButton = BlocConsumer<SurveyEditorBloc>(
        (_, value, __) => IconButton.filled(
          icon: Icon(value.icon, color: Colors.black87),
          onPressed: value.toggle,
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Editor'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<QuestionValidation>().submit();

              final everythingValid = ![
                questionNames.valid,
                for (final question in questions)
                  switch (question.question) {
                    YesNoQuestion() || TextPromptQuestion() => const [],
                    final MultipleChoice q => q.choices.valid,
                    final ScaleQuestion q => q.values.valid,
                  },
              ].contains(false);
              if (everythingValid) {
                customSurvey = [for (final q in questions) q.question];
                context.read<QuestionValidation>().reset();
                navigator.pop();
              }
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ReorderableListView(
                  shrinkWrap: true,
                  buildDefaultDragHandles: false,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex = min(newIndex, questions.length) - 1;
                    setState(() => questions.insert(newIndex, questions.removeAt(oldIndex)));
                  },
                  children: editors,
                ),
                divider(questions.length),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: editButton,
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

  @override
  void initState() {
    super.initState();
    node.addListener(() => setState(() => focused = node.hasPrimaryFocus));
  }

  static const presets = [
    YesNoQuestion('[question]'),
    TextPromptQuestion('[question]'),
    RadioQuestion('[question]'),
    CheckboxQuestion('[question]'),
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

    final bool expanded = isMobile || hovered || focused;

    final child = SizedBox(
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Divider(),
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

/// mobile device floating action button
class SurveyEditorBloc extends Cubit<bool> {
  SurveyEditorBloc() : super(false);

  IconData get icon => state ? Icons.done : Icons.edit;

  void toggle() => emit(!state);
}
