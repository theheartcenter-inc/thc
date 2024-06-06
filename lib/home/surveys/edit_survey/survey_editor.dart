import 'package:thc/home/surveys/edit_survey/survey_field_editor.dart';
import 'package:thc/home/surveys/survey_questions.dart';
import 'package:thc/the_good_stuff.dart';

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

class SurveyEditor extends StatefulWidget {
  const SurveyEditor(this.surveyType, this.questions, {super.key});

  final ThcSurvey surveyType;
  final List<SurveyQuestion> questions;

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
extension type KeyedQuestion.fromRecord((SurveyQuestion, Key) record) {
  /// {@macro Key}
  KeyedQuestion(SurveyQuestion question) : this.from(question, newKey);

  KeyedQuestion.from(SurveyQuestion question, Key key) : this.fromRecord((question, key));

  SurveyQuestion get question => record.$1;

  /// {@macro Key}
  Key get key => record.$2;

  /// {@macro Key}
  static Key get newKey => UniqueKey();

  /// Creates a new [KeyedQuestion] object: same question, different key.
  KeyedQuestion copy() => KeyedQuestion(question);

  /// Returns an updated [question] with the same [key].
  KeyedQuestion update(SurveyQuestion newQuestion) => KeyedQuestion.from(newQuestion, key);
}

class _SurveyEditorState extends State<SurveyEditor> {
  late final keyedQuestions = [for (final question in widget.questions) KeyedQuestion(question)];
  List<String> get questionNames => [for (final q in keyedQuestions) q.question.description];

  /// {@macro edit_survey.divider}
  SurveyEditDivider divider(int index) => SurveyEditDivider(
        (question) => setState(() => keyedQuestions.insert(index, KeyedQuestion(question))),
      );

  void validate() async {
    final checks = <bool>[
      questionNames.valid,
      for (final KeyedQuestion record in keyedQuestions)
        switch (record.question) {
          YesNoQuestion() || TextPromptQuestion() => true,
          final MultipleChoice q => q.choices.valid,
          final ScaleQuestion q => q.values.valid,
        },
    ];
    final validation = context.read<ValidSurveyQuestions>();

    if (checks.contains(false)) {
      validation.value = true;
      return;
    }

    final ThcSurvey survey = widget.surveyType;
    try {
      await Future.wait([
        survey.yeetResponses(),
        survey.newLength(keyedQuestions.length),
        for (final (i, q) in keyedQuestions.indexed) survey.doc(i).set(q.question.json),
      ]);
      navigator.snackbarMessage('saved!');
      validation.value = false;
      navigator.pop();
    } catch (e) {
      navigator.snackbarMessage('[error] $e');
    }
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
            if (keyedQuestions.isEmpty) context.read<Editing>().value = false;
          },
          validate: () => questionNames.validChoice(i),
          divider: divider(i),
        ),
    ];

    Widget? editButton;
    if (mobileDevice && keyedQuestions.isNotEmpty) {
      final editing = context.watch<Editing>();
      editButton = IconButton.filled(
        icon: Icon(
          editing.value ? Icons.done : Icons.calendar_view_day,
          color: Colors.black87,
        ),
        onPressed: editing.toggle,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Editor'),
        actions: [
          IconButton(
            onPressed: context.watch<Editing>().value ? null : validate,
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

/// {@template edit_survey.divider}
/// A horizontal line with a little "+" button.
///
/// You can press the button to insert a new question.
/// {@endtemplate}
class SurveyEditDivider extends HookWidget {
  /// {@macro edit_survey.divider}
  const SurveyEditDivider(this.addQuestion, {super.key});
  final void Function(SurveyQuestion) addQuestion;

  static const height = 60.0;

  static const presets = [
    YesNoQuestion('[question]'),
    TextPromptQuestion('[question]'),
    RadioQuestion('[question]'),
    CheckboxQuestion('[question]'),
    ScaleQuestion('[question]'),
  ];

  @override
  Widget build(BuildContext context) {
    final node = useFocusNode();
    final focus = useState(false);
    final hover = useState(false);

    if (context.watch<Editing>().value) {
      return const SizedBox(height: SurveyEditDivider.height / 2);
    }
    final Widget button;
    if (focus.value) {
      button = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final SurveyQuestion question in presets)
            InkWell(
              onTap: () {
                addQuestion(question);
                node.unfocus();
              },
              child: QuestionTypeIcon(question),
            ),
        ],
      );
    } else {
      button = InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        onTap: node.requestFocus,
        child: Padding(
          padding: EdgeInsets.all(hover.value ? 8 : 2),
          child: Opacity(
            opacity: hover.value ? 1 : 0.5,
            child: const Icon(Icons.add),
          ),
        ),
      );
    }

    final bool expanded = mobileDevice || hover.value || focus.value;

    final child = SizedBox(
      height: SurveyEditDivider.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Divider(),
          Focus(
            focusNode: node,
            onFocusChange: focus.update,
            child: TapRegion(
              onTapOutside: (_) => node.unfocus(),
              child: Card(
                clipBehavior: Clip.antiAlias,
                color: expanded ? null : ThcColors.of(context).surface,
                elevation: expanded ? null : 0,
                child: AnimatedSize(
                  duration: Durations.medium1,
                  curve: Curves.ease,
                  child: button,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (mobileDevice) return child;

    return MouseRegion(
      onEnter: (_) => hover.value = true,
      onExit: (_) => hover.value = false,
      child: child,
    );
  }
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
