import 'package:flutter/material.dart';
import 'package:thc/home/surveys/edit_survey/survey_field_editor.dart';
import 'package:thc/home/surveys/survey_questions.dart';
import 'package:thc/home/surveys/take_survey/survey.dart';
import 'package:thc/utils/bloc.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/app_config.dart';
import 'package:thc/utils/theme.dart';

/// This is meant for demonstration; the survey isn't saved to Firebase or local storage.
List<SurveyQuestion> customSurvey = [];

/// {@macro ValidSurveyQuestions}
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

/// {@template Key}
/// Let's say you start with this list:
/// ```dart
/// [SomeWidget(x: 1), SomeWidget(x: 2)];
/// ```
///
/// and end with this one:
/// ```dart
/// [SomeWidget(x: 2), SomeWidget(x: 1)];
/// ```
///
/// This could have happened a couple different ways:
///
/// ```dart
/// // maybe they got swapped
/// newList = [oldList.last, oldList.first];
///
/// // maybe both values were changed
/// list[0].x = 2;
/// list[1].x = 1;
/// ```
///
/// Flutter avoids getting confused by using the Widget's [Key].
///
/// ```dart
/// [SomeWidget(key: Key('1'), x: 1), SomeWidget(key: Key('2'), x: 2)];
///
/// // got swapped
/// [SomeWidget(key: Key('2'), x: 2), SomeWidget(key: Key('1'), x: 1)];
///
/// // values changed
/// [SomeWidget(key: Key('1'), x: 2), SomeWidget(key: Key('2'), x: 1)];
/// ```
///
/// A [ReorderableList] requires that each item has a unique key,
/// to prevent any confusion about which values are being swapped.
/// {@endtemplate}
///
/// This extension type attaches a [UniqueKey] to each question so they can be reordered.
extension type KeyedQuestion.from((SurveyQuestion, Key) record) {
  /// {@macro Key}
  KeyedQuestion(SurveyQuestion question) : this.from((question, newKey));

  SurveyQuestion get question => record.$1;

  /// {@macro Key}
  Key get key => record.$2;

  /// {@macro Key}
  static Key get newKey => UniqueKey();

  /// Creates a new [KeyedQuestion] object: same question, different key.
  KeyedQuestion copy() => KeyedQuestion.from((question, newKey));

  /// Returns an updated [question] with the same [key].
  KeyedQuestion update(SurveyQuestion newQuestion) => KeyedQuestion.from((newQuestion, key));
}

class _SurveyEditorState extends State<SurveyEditor> {
  final keyedQuestions = [for (final question in customSurvey) KeyedQuestion(question)];
  List<String> get questionNames => [for (final q in keyedQuestions) q.question.description];

  /// {@macro edit_survey.divider}
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
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Center(
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
      ),
      floatingActionButton: editButton,
    );
  }
}

/// {@template edit_survey.divider}
/// A horizontal line with a little "+" button.
///
/// You can press the button to insert a new question.
/// {@endtemplate}
class SurveyEditDivider extends StatefulWidget {
  /// {@macro edit_survey.divider}
  const SurveyEditDivider(this.addQuestion, {super.key});
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

    final bool expanded = mobileDevice || hovered || focused;

    final child = SizedBox(
      height: SurveyEditDivider.height,
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

    if (mobileDevice) return child;

    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true),
      onExit: (_) => setState(() => hovered = false),
      child: child,
    );
  }
}

/// You can see options for duplicating, deleting, and reordering survey questions
/// when you hover your mouse over the question.
///
/// Mobile devices don't have mouse cursors,
/// so instead there's a button that uses this BLoC to show/hide the extra options.
class MobileEditing extends Cubit<bool> {
  MobileEditing() : super(false);

  IconData get icon => state ? Icons.done : Icons.calendar_view_day;

  void toggle() => emit(!state);
}

/// {@template ValidSurveyQuestions}
/// In order for a custom survey to work, we need a valid list of question names,
/// and each question with multiple [String] values needs its list to be valid too.
///
/// A list is "valid" if:
/// - it's non-empty
/// - there are no duplicate items
/// {@endtemplate}
class ValidSurveyQuestions extends Cubit<bool> {
  /// {@macro ValidSurveyQuestions}
  ValidSurveyQuestions() : super(false);
}
