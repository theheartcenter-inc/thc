import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:thc/models/bloc.dart';
import 'package:thc/models/navigator.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/survey/survey_field.dart';
import 'package:thc/views/survey/survey_questions.dart';
import 'package:thc/views/survey/survey_screen.dart';

/// This is meant for demonstration; the survey isn't saved to Firebase or local storage.
List<SurveyQuestion> customSurvey = [];

final isMobile = switch (Platform.operatingSystem) { 'ios' || 'android' => true, _ => false };

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

/// mobile device floating action button
class SurveyEditorBloc extends Cubit<bool> {
  SurveyEditorBloc() : super(false);

  IconData get icon => state ? Icons.done : Icons.edit;

  void toggle() => emit(!state);
}

class SurveyFieldEditor extends StatefulWidget {
  const SurveyFieldEditor({
    required this.divider,
    required this.question,
    required this.index,
    required this.update,
    required this.duplicate,
    required this.validate,
    required this.yeet,
    super.key,
  });
  final SurveyEditDivider divider;
  final SurveyQuestion question;
  final int index;
  final ValueChanged<SurveyQuestion> update;
  final VoidCallback duplicate;
  final ValueGetter<bool> validate;
  final VoidCallback yeet;

  @override
  State<SurveyFieldEditor> createState() => _SurveyFieldEditorState();
}

class ChoiceText extends StatelessWidget {
  ChoiceText(
    this.data, {
    required this.index,
    required this.plural,
    required this.mainNode,
    required this.icon,
    required this.onChanged,
    required this.onEditingComplete,
    required this.yeet,
    required this.onHover,
  }) : super(key: data.key);

  final TextFieldData data;
  final int index;
  final bool plural;
  final FocusNode mainNode;
  final IconData? icon;
  final ValueChanged<String> onChanged;
  final VoidCallback onEditingComplete;
  final VoidCallback? yeet;
  final ValueChanged<bool> onHover;

  @override
  Widget build(BuildContext context) {
    final text = TextField(
      controller: data.controller,
      focusNode: data.node,
      decoration: InputDecoration(errorText: data.errorText),
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onTapOutside: (_) => mainNode.requestFocus(),
    );

    if (!plural) return text;

    final bool? useDataIcon = switch (icon) {
      _ when data.showIcons => true,
      null => null,
      _ => false,
    };

    final widget = Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: IconButton(
            style: TextButton.styleFrom(
              foregroundColor: switch (useDataIcon) {
                true => context.colorScheme.error,
                false => context.colorScheme.outlineVariant,
                null => Colors.transparent,
              },
            ),
            onPressed: yeet,
            icon: Icon((useDataIcon ?? true) ? Icons.do_not_disturb_on_outlined : icon!),
          ),
        ),
        Expanded(child: text),
        ReorderableDragStartListener(
          index: index,
          child: Opacity(
            opacity: data.showIcons ? 0.5 : 0,
            child: const Padding(
              padding: EdgeInsets.only(top: 8, left: 12),
              child: Icon(Icons.reorder),
            ),
          ),
        ),
      ],
    );

    if (isMobile) return widget;

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: widget,
    );
  }
}

class TextFieldData {
  TextFieldData(String text, [this.handler]) : controller = TextEditingController(text: text);

  final TextEditingController controller;
  final FocusOnKeyEventCallback Function(TextFieldData)? handler;
  late final FocusNode node = FocusNode(onKeyEvent: handler?.call(this));
  final Key key = UniqueKey();
  bool showIcons = isMobile;
  int get index => key.hashCode;

  String get text => controller.text;
  set text(String newText) {
    controller.text = newText;
  }

  String? errorText;
}

enum EditorMode {
  view,
  edit,
  collapsed;

  factory EditorMode.update(List<FocusNode> nodes) =>
      nodes.any((node) => node.hasFocus) ? edit : view;
}

class _SurveyFieldEditorState extends State<SurveyFieldEditor> {
  EditorMode mode = EditorMode.collapsed;
  void stopEditing() => mode = switch (mode) {
        EditorMode.view || EditorMode.edit => EditorMode.view,
        EditorMode.collapsed => EditorMode.collapsed,
      };

  late final SurveyQuestion q = widget.question;
  final mainNode = FocusNode();

  late final titleData = TextFieldData(q.description);

  late bool optional = q.optional;
  final optionalNode = FocusNode();

  /// A checkbox either for "show endpoints" or "allow custom response",
  /// depending on the question type.
  late bool? otherToggle = switch (q) {
    YesNoQuestion() || TextPromptQuestion() => null,
    final MultipleChoice q => q.canType,
    final ScaleQuestion q => q.showEndLabels,
  };
  late final otherCheckboxNode = otherToggle == null ? null : FocusNode();

  List<FocusNode> get allNodes => [
        mainNode,
        titleData.node,
        optionalNode,
        if (otherCheckboxNode case final node?) node,
        for (final choice in choices) choice.node,
      ];

  SurveyQuestion get updatedQuestion {
    final description = titleData.text.trim();
    final choices = [for (final choice in this.choices) choice.text.trim()];
    return switch (q) {
      YesNoQuestion() => YesNoQuestion(description, optional: optional),
      TextPromptQuestion() => TextPromptQuestion(description, optional: optional),
      RadioQuestion() => RadioQuestion(
          description,
          optional: optional,
          choices: choices,
          canType: otherToggle!,
        ),
      CheckboxQuestion() => CheckboxQuestion(
          description,
          optional: optional,
          choices: choices,
          canType: otherToggle!,
        ),
      ScaleQuestion() => ScaleQuestion(
          description,
          optional: optional,
          values: choices,
          showEndLabels: otherToggle!,
        ),
    };
  }

  late final List<TextFieldData> choices;
  IconData? get choiceIcon => switch (q) {
        RadioQuestion() => Icons.radio_button_unchecked,
        CheckboxQuestion() => Icons.check_box_outlined,
        _ => null,
      };

  void addChoice() {
    setState(() => choices.add(TextFieldData('', yeetChoice)));
    choices.last.node.requestFocus();
  }

  FocusOnKeyEventCallback yeetChoice(TextFieldData option) => (node, event) {
        if (event is KeyUpEvent) return KeyEventResult.ignored;
        int index = choices.indexOf(option);
        switch (event.logicalKey) {
          case LogicalKeyboardKey.arrowUp when index > 0:
            choices[index - 1].node.requestFocus();
          case LogicalKeyboardKey.arrowDown when index < choices.length - 1:
            choices[index + 1].node.requestFocus();

          case LogicalKeyboardKey.delete || LogicalKeyboardKey.backspace:
            if (option.controller.text.isNotEmpty || choices.length == 1) {
              return KeyEventResult.ignored;
            }
            setState(() => choices.removeAt(index));
            if (event.logicalKey == LogicalKeyboardKey.backspace || index == choices.length) {
              index--;
            }
            choices[index].node.requestFocus();
          default:
            return KeyEventResult.ignored;
        }
        return KeyEventResult.handled;
      };

  static const duration = Durations.short4;
  @override
  void initState() {
    super.initState();

    final options = switch (q) {
      YesNoQuestion() || TextPromptQuestion() => const [],
      final MultipleChoice q => q.choices.toList(),
      final ScaleQuestion q => q.values.toList(),
    };
    choices = [
      for (final option in options) TextFieldData(option, yeetChoice),
    ];

    for (final node in allNodes) {
      node.addListener(() {
        if (mode == EditorMode.collapsed) return;
        final newState = EditorMode.update(allNodes);
        if (mode != newState) {
          setState(() {
            mode = newState;
            if (showButtons) showButtons = false;
          });
          if (newState == EditorMode.view) widget.update(updatedQuestion);
        }
      });
    }
    Future.delayed(
      const Duration(milliseconds: 1),
      () => setState(() => mode = EditorMode.view),
    );
  }

  bool showButtons = false;
  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final translucent = colors.outlineVariant;
    final pluralChoices = choices.length > 1;

    final choiceNames = [for (final choice in choices) choice.text];
    const choicePadding = EdgeInsets.fromLTRB(48, 0, 36, 16);

    final validating = context.watch<QuestionValidation>().state;
    final mobileEditing = context.watch<SurveyEditorBloc>().state;
    if (mobileEditing) stopEditing();

    Widget? content;
    switch (mode) {
      case EditorMode.edit:
        if (validating) {
          titleData.errorText = switch (widget.validate()) {
            true => null,
            false when titleData.text.valid => 'duplicate question title',
            false => 'type a question title',
          };
          for (final (i, choiceData) in choices.indexed) {
            choiceData.errorText = switch (choiceNames.validChoice(i)) {
              true => null,
              false when choiceData.text.valid => 'duplicate choice',
              false => 'type an answer',
            };
          }
        }
        final choiceEditors = [
          for (final (i, choiceData) in choices.indexed)
            ChoiceText(
              choiceData,
              index: i,
              plural: pluralChoices,
              mainNode: mainNode,
              icon: choiceIcon,
              onChanged: (text) {
                if (!validating) return;
                widget.update(updatedQuestion);
              },
              onEditingComplete: () {
                if (choices.elementAtOrNull(i + 1) case final next?) {
                  next.node.requestFocus();
                } else {
                  addChoice();
                }
              },
              onHover: (hovering) => setState(() => choices[i].showIcons = hovering),
              yeet: () => setState(() => choices.removeAt(i)),
            )
        ];
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(errorText: titleData.errorText),
              controller: titleData.controller,
              focusNode: titleData.node,
              onChanged: (text) {
                if (!validating) return;
                widget.update(updatedQuestion);
              },
              onSubmitted: (_) => mainNode.requestFocus(),
              onTapOutside: (_) => mainNode.requestFocus(),
            ),
            if (choices.isNotEmpty) ...[
              if (pluralChoices)
                ReorderableListView(
                  shrinkWrap: true,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    setState(() => choices.insert(newIndex, choices.removeAt(oldIndex)));
                  },
                  buildDefaultDragHandles: false,
                  children: choiceEditors,
                )
              else
                Padding(
                  padding: choicePadding.copyWith(top: 16),
                  child: choiceEditors.single,
                ),
              Padding(
                padding: choicePadding,
                child: Stack(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'add…',
                        hintStyle: TextStyle(color: translucent),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: translucent),
                        ),
                      ),
                    ),
                    Positioned.fill(child: InkWell(onTap: addChoice)),
                  ],
                ),
              ),
            ],
            Row(
              children: [
                if (otherToggle case final value?)
                  Expanded(
                    child: SwitchListTile.adaptive(
                      controlAffinity: ListTileControlAffinity.leading,
                      value: value,
                      onChanged: (_) => setState(() => otherToggle = !value),
                      title: Text(
                        q is MultipleChoice ? 'add "other" option' : 'show endpoint labels',
                      ),
                    ),
                  ),
                Expanded(
                  child: SwitchListTile.adaptive(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: !optional,
                    onChanged: (_) => setState(() => optional = !optional),
                    title: const Text('required'),
                  ),
                ),
              ],
            ),
          ],
        );
      case EditorMode.view:
        content = Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Theme(
              data: context.theme.copyWith(
                listTileTheme: ListTileThemeData(textColor: colors.onBackground),
                iconTheme: IconThemeData(color: colors.onBackground),
              ),
              child: SurveyField(SurveyRecord.init(updatedQuestion), (_) {}),
            ),
            Positioned.fill(child: InkWell(onTap: mainNode.requestFocus)),
            if (showButtons || mobileEditing) ...[
              if (mobileEditing) const Positioned.fill(child: ColoredBox(color: Colors.white38)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: widget.duplicate,
                    child: const Icon(Icons.copy),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: colors.error),
                    onPressed: () async {
                      setState(() => mode = EditorMode.collapsed);
                      await Future.delayed(duration);
                      widget.yeet();
                    },
                    child: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              Positioned.fill(
                right: 8,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ReorderableDragStartListener(
                    index: widget.index,
                    child: Opacity(
                      opacity: isMobile ? 1 : 0.5,
                      child: const Icon(Icons.reorder),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
        if (validating) {
          final validQuestion = widget.validate();
          if (!validQuestion || (choiceNames.isNotEmpty && !choiceNames.valid)) {
            content = ColoredBox(
              color: colors.errorContainer,
              child: content,
            );
          }
        }

        if (!isMobile) {
          content = MouseRegion(
            onEnter: (_) => setState(() => showButtons = true),
            onExit: (_) => setState(() => showButtons = false),
            child: content,
          );
        }
      case EditorMode.collapsed:
        break;
    }

    if (content != null) {
      content = Column(
        children: [
          widget.divider,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.translucent,
              child: Focus(focusNode: mainNode, child: content),
            ),
          ),
        ],
      );
    }

    return AnimatedSize(
      curve: Curves.ease,
      duration: duration,
      child: content ?? const SizedBox(width: double.infinity),
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

class QuestionValidation extends Cubit<bool> {
  QuestionValidation() : super(false);

  void submit() => state ? null : emit(true);
  void reset() => state ? emit(false) : null;
}
