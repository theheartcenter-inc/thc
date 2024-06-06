import 'package:flutter/material.dart' as material;
import 'package:thc/the_good_stuff.dart';

@Deprecated('use "Dialog" instead.')
typedef AlertDialog = material.AlertDialog;

@Deprecated('use "navigator" (not capitalized) instead.')
typedef Navigator = material.Navigator;

@Deprecated('use "navigator.showDialog" instead.')
const showDialog = material.showDialog;

@Deprecated('use "navigator.showDialog" instead.')
const showAdaptiveDialog = material.showAdaptiveDialog;

@Deprecated('use "navigator.snackbarMessage" instead.')
typedef ScaffoldMessenger = material.ScaffoldMessenger;

/// We're storing fonts in the `assets/` folder
/// to keep the app appearance consistent across devices.
///
/// Both "pretendard" and "roboto mono" are open-source fonts with variable weight.
class TextStyle extends material.TextStyle {
  /// "Pretendard" is almost exactly like the default Apple typeface,
  /// but it's open-source and free to use!
  const TextStyle({
    double? size,
    this.weight,
    super.inherit,
    super.color,
    super.backgroundColor,
    super.letterSpacing,
    super.wordSpacing,
    super.textBaseline,
    super.height,
    super.leadingDistribution,
    super.locale,
    super.foreground,
    super.background,
    super.shadows,
    super.decoration,
    super.decorationColor,
    super.decorationStyle,
    super.decorationThickness,
    super.overflow,
  }) : super(fontSize: size, fontFamily: 'pretendard');

  /// "Roboto mono" is a monospace font,
  /// i.e. a font you'd see with typewriters and code editors.
  const TextStyle.mono({
    double? size,
    this.weight,
    super.fontStyle,
    super.inherit,
    super.color,
    super.backgroundColor,
    super.letterSpacing,
    super.wordSpacing,
    super.textBaseline,
    super.height,
    super.leadingDistribution,
    super.locale,
    super.foreground,
    super.background,
    super.shadows,
    super.decoration,
    super.decorationColor,
    super.decorationStyle,
    super.decorationThickness,
    super.overflow,
  }) : super(fontSize: size, fontFamily: 'roboto mono');

  /// In [StyleText.mono], the value can range from 100 to 700;
  /// otherwise, it can go from 50 to 1000.
  final double? weight;

  @override
  List<FontVariation>? get fontVariations {
    return [
      if (weight case final w?) FontVariation.weight(w),
    ];
  }
}

class Dialog extends StatelessWidget {
  const Dialog({
    super.key,
    required this.titleText,
    this.bodyText,
    this.body,
    this.actionsAlignment = MainAxisAlignment.end,
  }) : assert(
          (body == null) != (bodyText == null),
          'exactly one of "body" and "bodyText" should be provided.',
        );

  const factory Dialog.confirm({
    Key? key,
    required String titleText,
    String? bodyText,
    Widget? body,
    VoidCallback? onConfirm,
    (String no, String yes) actionText,
    MainAxisAlignment actionsAlignment,
  }) = _Confirmation;

  final String titleText;
  final String? bodyText;
  final Widget? body;
  final MainAxisAlignment actionsAlignment;

  List<Widget> get _actions => [TextButton(onPressed: navigator.pop, child: const Text('OK'))];

  @override
  Widget build(BuildContext context) {
    return material.AlertDialog.adaptive(
      title: Text(titleText),
      content: body ?? Text(bodyText!),
      actions: _actions,
    );
  }
}

class _Confirmation extends Dialog {
  const _Confirmation({
    super.key,
    required super.titleText,
    super.bodyText,
    super.body,
    this.onConfirm,
    this.actionText = ('back', 'continue'),
    super.actionsAlignment = MainAxisAlignment.end,
  });

  final (String no, String yes) actionText;
  final VoidCallback? onConfirm;

  @override
  List<Widget> get _actions {
    final (cancel, ok) = actionText;
    return [
      TextButton(onPressed: navigator.pop, child: Text(cancel)),
      TextButton(onPressed: onConfirm ?? () => navigator.pop(true), child: Text(ok)),
    ];
  }
}

class ErrorDialog extends Dialog {
  const ErrorDialog(String text, {super.key})
      : super(titleText: 'An error occurred', bodyText: text);
}
