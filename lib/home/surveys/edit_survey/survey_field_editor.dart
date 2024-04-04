import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:thc/home/surveys/edit_survey/survey_editor.dart';
import 'package:thc/home/surveys/survey_questions.dart';
import 'package:thc/home/surveys/take_survey/survey_field.dart';
import 'package:thc/utils/platform.dart';
import 'package:thc/utils/theme.dart';

/// Shows a preview of a [SurveyField] that you can tap to edit.
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

/// Whether it's a radio, checkbox, or scale question,
/// you need an ability to add, remove, and reorder choices.
///
/// The `ChoiceText` widget has a bunch of [TextField]s
/// in a [ReorderableListView] to accomplish this.
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

  /// This item's index in the choice list.
  final int index;

  /// Set to `true`, unless there's currently only 1 choice.
  final bool plural;

  /// The main focus node of the enclosing [SurveyFieldEditor].
  final FocusNode mainNode;

  /// The checkbox/radio icon to use, if applicable.
  final IconData? icon;

  /// Updates the question data based on what's currently being typed.
  final ValueChanged<String> onChanged;

  /// When the user hits "enter", move to the next choice
  /// (or add another choice if we're at the end of the list).
  final VoidCallback onEditingComplete;

  /// Delete this choice.
  final VoidCallback? yeet;

  /// On desktop platforms, the "delete" and "reorder" icons are hidden
  /// until you hover your mouse cursor on the choice.
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
            focusNode: FocusNode(skipTraversal: true),
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

    if (mobileDevice) return widget;

    return MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: widget,
    );
  }
}

/// {@template TextFieldData}
/// A handy class that stores all the data relating to a single [TextField].
/// {@endtemplate}
class TextFieldData {
  /// {@macro TextFieldData}
  TextFieldData(String text, [this.handler]) : controller = TextEditingController(text: text);

  final TextEditingController controller;

  /// stores the keyboard shortcuts from [_SurveyFieldEditorState.keyboardShortcuts].
  final FocusOnKeyEventCallback Function(TextFieldData)? handler;

  /// The keyboard shortcut [handler] is active when this [node] is focused.
  late final FocusNode node = FocusNode(onKeyEvent: handler?.call(this));

  /// A unique key to use for the text field widget.
  final Key key = UniqueKey();

  /// Determines whether "delete" and "reorder" icons are shown.
  bool showIcons = mobileDevice;

  String get text => controller.text;
  set text(String newText) {
    controller.text = newText;
  }

  /// Once [ValidSurveyQuestions] is triggered,
  /// options that are empty or duplicates will have an error message.
  String? errorText;
}

enum EditorMode {
  /// The editor will show a preview of the [SurveyField],
  /// and you can tap to edit.
  view,

  /// The survey field is being edited.
  edit,

  /// The editor only exists in [collapsed] mode very briefly,
  /// to make an animation when it's being added or deleted.
  collapsed;

  factory EditorMode.update(List<FocusNode> nodes) =>
      nodes.any((node) => node.hasFocus) ? edit : view;
}

class _SurveyFieldEditorState extends State<SurveyFieldEditor> {
  EditorMode mode = EditorMode.collapsed;
  void stopEditing() {
    if (mode == EditorMode.edit) mode = EditorMode.view;
  }

  late final SurveyQuestion q = widget.question;
  final mainNode = FocusNode();

  late final titleData = TextFieldData(q.description);

  /// Controls whether this is a required question.
  ///
  /// We need to use the name `optional`, since `required` is already a Dart keyword.
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
        for (final textFieldData in choices) textFieldData.node,
      ];

  /// Creates an updated [SurveyQuestion] based on the current state of the editor.
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

  /// Stores the name of each choice in this question (if applicable),
  /// plus some other data.
  late final List<TextFieldData> choices;
  IconData? get choiceIcon => switch (q) {
        RadioQuestion() => Icons.radio_button_unchecked,
        CheckboxQuestion() => Icons.check_box_outlined,
        _ => null,
      };

  void addChoice() {
    setState(() => choices.add(TextFieldData('', keyboardShortcuts)));
    choices.last.node.requestFocus();
  }

  /// You can use the arrow keys to navigate between choices,
  /// and "backspace" will delete an empty choice.
  FocusOnKeyEventCallback keyboardShortcuts(TextFieldData option) => (node, event) {
        if (event is KeyUpEvent) return KeyEventResult.ignored;
        int index = choices.indexOf(option);
        switch (event.logicalKey) {
          case LogicalKeyboardKey.arrowUp when index > 0:
            choices[index - 1].node.requestFocus();
          case LogicalKeyboardKey.arrowDown when index < choices.length - 1:
            choices[index + 1].node.requestFocus();

          case LogicalKeyboardKey.delete || LogicalKeyboardKey.backspace:
            if (option.controller.text.isNotEmpty ||
                choices.length == 1 ||
                (index == 0 && event.logicalKey == LogicalKeyboardKey.backspace)) {
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

  /// The duration of the animation for moving to and from [EditorMode.collapsed].
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
      for (final option in options) TextFieldData(option, keyboardShortcuts),
    ];

    // when nothing in this editor is focused, we should return to "view" mode.
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

    // we need to delay this,
    // since there wouldn't be any animation if we just set the value immediately.
    Future.delayed(
      const Duration(milliseconds: 5),
      () => setState(() => mode = EditorMode.view),
    );
  }

  @override
  void dispose() {
    for (final node in allNodes) {
      node.dispose();
    }
    titleData.controller.dispose();
    for (final choiceData in choices) {
      choiceData.controller.dispose();
    }
    super.dispose();
  }

  /// Controls whether duplicate/delete/reorder icons are shown.
  bool showButtons = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final translucent = colors.outlineVariant;
    final pluralChoices = choices.length > 1;

    final choiceNames = [for (final choice in choices) choice.text];
    const choicePadding = EdgeInsets.fromLTRB(48, 0, 36, 16);

    final validating = context.watch<ValidSurveyQuestions>().state;
    final mobileEditing = context.watch<MobileEditing>().state;
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
              yeet: () {
                setState(() => choices.removeAt(i));
                choiceData.controller.dispose();
                choiceData.node.dispose();
              },
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
        final Widget dragHandle;
        if (mobileDevice) {
          dragHandle = const ColoredBox(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.reorder, size: 28),
            ),
          );
        } else {
          dragHandle = const Opacity(opacity: 0.5, child: Icon(Icons.reorder));
        }
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
                  child: ReorderableDragStartListener(index: widget.index, child: dragHandle),
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
        if (mobileEditing) {
          content = Padding(
            padding: const EdgeInsets.only(bottom: SurveyEditDivider.height / 2),
            child: content,
          );
        } else if (!mobileDevice) {
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

/// {@template QuestionTypeIcon}
/// Cute little icons to show when adding a question.
/// {@endtemplate}
class QuestionTypeIcon extends StatelessWidget {
  /// {@macro QuestionTypeIcon}
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
                ? null // no border on the far right side
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
