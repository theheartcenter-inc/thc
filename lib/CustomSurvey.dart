import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thc/surveys/edit_survey/survey_field_editor.dart';
import 'package:thc/surveys/survey_questions.dart';
import 'package:thc/surveys/take_survey/survey.dart';
import 'package:thc/utils/app_config.dart';
import 'package:thc/utils/bloc.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/theme.dart';

List<SurveyQuestion> customSurvey = [];

extension ValidChoices on List<String> {
  bool validChoice(int index, [String? choice]) {
    choice ??= this[index];
    return choice.valid && !sublist(0, index).contains(choice);
  }

  bool get valid => indexed.every((item) => validChoice(item.$1, item.$2));
}

class ViewCustomSurvey extends StatelessWidget {
  const ViewCustomSurvey({Key? key}) : super(key: key);

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
  const SurveyEditor({Key? key}) : super(key: key);

  @override
  State<SurveyEditor> createState() => _SurveyEditorState();
}

sealed class FirestoreAPI {
  static void sendCustomSurveyToFirestore(List<SurveyQuestion> survey) {
    CollectionReference surveys = FirebaseFirestore.instance.collection('surveys');
    List<Map<String, dynamic>> surveyData = survey.map((question) => question.toJson()).toList();

    surveys.add({'questions': surveyData})
        .then((value) => print("Survey data added to Firestore"))
        .catchError((error) => print("Failed to add survey data: $error"));
  }
}

class _SurveyEditorState extends State<SurveyEditor> {
  final keyedQuestions = [for (final question in customSurvey) KeyedQuestion(question)];
  List<String> get questionNames => [for (final q in keyedQuestions) q.question.description];

  SurveyEditDivider divider(int index) => SurveyEditDivider(
        (question) => setState(() => keyedQuestions.insert(index, KeyedQuestion(question))),
      );

  void validate() {
    final checks = [
      questionNames.valid,
      for (final record in keyedQuestions)
        switch (record.question) {
          YesNoQuestion() || TextPromptQuestion() => true,
          final MultipleChoice q => q.choices.valid,
          final ScaleQuestion q => q.values.valid,
        },
    ];
    final validation = context.read<ValidSurveyQuestions>();

    if (checks.contains(false)) return validation.emit(true);

    customSurvey = [for (final q in keyedQuestions) q.question];
    FirestoreAPI.sendCustomSurveyToFirestore(customSurvey); // Your code to send the survey data to Firebase Firestore goes here
    validation.emit(false);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final editors = [
      for (final (i, record) in keyedQuestions.indexed)
        SurveyFieldEditor(
          key: record.key,
          index: i,
          question: record.question,
          update: (newValue) => setState(
            () => keyedQuestions[i] = keyedQuestions[i].update(newValue),
          ),
          duplicate: () => setState(() => keyedQuestions.insert(i + 1, record.copy())),
          yeet: () {
            setState(() => keyedQuestions.removeAt(i));
            if (keyedQuestions.isEmpty) context.read<MobileEditing>().emit(false);
          },
          validate: () => questionNames.validChoice(i),
          divider: divider(i),
        ),
    ];

    Widget? editButton;
    if (mobileDevice && keyedQuestions.isNotEmpty) {
      editButton = IconButton.filled(
        icon: Icon(context.watch<MobileEditing>().icon, color: Colors.black87),
        onPressed: context.read<MobileEditing>().toggle,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Editor'),
        actions: [
          IconButton(
            onPressed: context.watch<MobileEditing>().state ? null : validate,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ReorderableListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                buildDefaultDragHandles: false,
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex--;
                  setState(() {
                    keyedQuestions.insert(newIndex, keyedQuestions.removeAt(oldIndex));
                  });
                },
                children: editors,
              ),
              divider(keyedQuestions.length),
            ],
          ),
        ),
      ),
      floatingActionButton: editButton,
    );
  }
}

class SurveyEditDivider extends StatefulWidget {
  const SurveyEditDivider(this.addQuestion, {Key? key}) : super(key: key);
  final void Function(SurveyQuestion) addQuestion;

  static const height = 60.0;

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

  @override
  void dispose() {
    node.dispose();
    super.dispose();
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
    if (context.watch<MobileEditing>().state) {
      return const SizedBox(height: SurveyEditDivider.height / 2);
    }
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
          child: Opacity(
            opacity: hovered ? 1 : 0.5,
            child: const Icon(Icons.add),
          ),
        ),
      );
    }

    final
