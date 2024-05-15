import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thc/start/src/bottom_stuff.dart';
import 'package:thc/start/src/login_progress.dart';
import 'package:thc/start/src/za_hando.dart';
import 'package:thc/utils/app_config.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/clip_height.dart';
import 'package:thc/utils/widgets/enum_widget.dart';

/// We could have done something like
///
/// ```dart
/// final nodes = [FocusNode(), FocusNode()];
/// FocusNode get node => nodes[index];
/// ```
///
/// but I like how [Record] types are immutable
/// (and I'm pretty sure they have better performance).
extension LoginFieldStuff<T> on (T, T) {
  T get(LoginField field) => switch (field) {
        LoginField.top => $1,
        LoginField.bottom => $2,
      };
}

/// Holds UI/state management data for the username & password fields
/// (or whatever the currently applicable [LoginLabels] are).
enum LoginField with StatelessEnum {
  top,
  bottom;

  static final controllers = (TextEditingController(), TextEditingController());
  static final nodes = (FocusNode(), FocusNode());

  TextEditingController get controller => controllers.get(this);
  FocusNode get node => nodes.get(this);

  /// This listener is added to each node when the [LoginProgressTracker] bloc
  /// is first created.
  Future<void> listener() async {
    if (node.hasFocus) {
      LoginProgressTracker.update(focusedField: this);
      return;
    }
    await Future.delayed(const Duration(milliseconds: 50));
    LoginProgressTracker.unfocus(this);
  }

  void newVal(String? value) {
    final current = LoginProgressTracker.readState.fieldValues;
    LoginProgressTracker.update(
      fieldValues: switch (this) {
        top => (value, current.$2),
        bottom => (current.$1, value),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final LoginProgress(
      :labels,
      :focusedField,
      :animation,
      :fieldValues,
      :showPassword,
    ) = LoginProgressTracker.of(context);

    final maybeSubmit = this == bottom || labels.just1field
        ? LoginProgressTracker.maybeSubmit()
        : ([_]) async {
            await Future.delayed(Durations.short1);
            bottom.node.requestFocus();
          };

    final colors = ThcColors.of(context);
    final focused = focusedField == this;
    final cursorColor = context.lightDark(ThcColors.green67, Colors.black);
    final blackHint = focused && colors.brightness == Brightness.dark;
    final hintText = animation >= AnimationProgress.showBottom || focusedField != null
        ? switch (this) { top => labels.topHint, bottom => labels.bottomHint }
        : null;

    final textField = TextField(
      controller: controller,
      focusNode: node,
      cursorColor: cursorColor,
      decoration: InputDecoration(
        border: InputBorder.none,
        hoverColor: Colors.transparent,
        fillColor: focused
            ? context.lightDark(Colors.white54, ThcColors.lightContainer16)
            : Colors.transparent,
        filled: true,
        hintText: hintText,
        hintStyle: StyleText(color: blackHint ? Colors.black : colors.outline),
      ),
      obscureText: !(this == top && showPassword) && (hintText?.contains('password') ?? false),
      onChanged: newVal,
      onSubmitted: maybeSubmit,
    );

    if (this == top) return textField;

    const height = 48.0;
    return AnimatedContainer(
      duration: Durations.medium1,
      curve: Curves.ease,
      height: fieldValues.$2 == null || labels.just1field ? 0 : height,
      width: double.infinity,
      child: ClipHeight(childHeight: height, child: textField),
    );
  }
}

/// {@template LoginFields}
/// This widget holds everything in the main UI box,
/// including the [LoginField]s and the [BottomStuff].
/// {@endtemplate}
class LoginFields extends StatelessWidget {
  /// {@macro LoginFields}
  const LoginFields({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginProgress(
      :animation,
      :labels,
      :fieldValues,
      :errorMessage,
    ) = LoginProgressTracker.of(context);

    final colors = ThcColors.of(context);

    final expandText = animation >= AnimationProgress.collapseHand;
    final showBottom = animation >= AnimationProgress.showBottom;

    late final startButton = TextButton(
      onPressed: animation >= AnimationProgress.pressStart ? null : animate,
      child: AnimatedOpacity(
        duration: Durations.extralong4,
        opacity: expandText ? 0 : 1,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 3),
            child: Text(
              'start',
              style: StyleText(size: 22, weight: 600, color: ThcColors.green),
            ),
          ),
        ),
      ),
    );

    final fancyField = Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 2),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          AnimatedContainer(
            duration: Durations.extralong4,
            curve: Curves.easeInOutQuart,
            width: expandText ? 400 : 125,
            decoration: BoxDecoration(
              border: expandText
                  ? null
                  : Border.all(
                      color: ThcColors.green,
                      width: 2.5,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
              borderRadius: BorderRadius.all(Radius.circular(expandText ? 8 : 0x100)),
            ),
            clipBehavior: Clip.antiAlias,
            child: ColoredBox(
              color: colors.surfaceTint.withAlpha(expandText ? 0x40 : 0xa0),
              child: const Column(children: LoginField.values),
            ),
          ),
          Positioned.fill(child: showBottom ? const SizedBox.shrink() : startButton),
          const _TextFieldButton(),
          if (labels.choosingPassword && fieldValues.$1!.isNotEmpty)
            const _TextFieldButton.passwordVisibility(),
        ],
      ),
    );

    final Widget helpText;
    if (errorMessage != null) {
      helpText = Text(
        errorMessage.isNotEmpty
            ? errorMessage
            : 'check the above field${labels.just1field ? "" : "s"} and try again.',
        textAlign: TextAlign.center,
        style: const StyleText(size: 12, weight: 600, color: Color(0xffc00000)),
      );
    } else if (labels == LoginLabels.recovery) {
      helpText = Text(
        "If you don't have a connected email,\ncontact the person who provided your user ID.",
        textAlign: TextAlign.center,
        style: StyleText(size: 12, weight: 550, color: colors.onSurface),
      );
    } else {
      helpText = const SizedBox(width: double.infinity);
    }

    return Column(
      children: [
        fancyField,
        AnimatedSize(duration: Durations.medium1, curve: Curves.ease, child: helpText),
        if (showBottom) const BottomStuff(),
      ],
    );
  }
}

/// A button for the [LoginFields] with adaptive foreground/background colors.
class _TextFieldButton extends StatelessWidget {
  /// Checkmark button—submit the text currently in the fields.
  const _TextFieldButton() : passwordVisibility = false;

  /// Show/hide the password.
  const _TextFieldButton.passwordVisibility() : passwordVisibility = true;

  final bool passwordVisibility;

  /// This node ensures that pressing 'Tab' takes you straight to the next field,
  /// not to the [_TextFieldButton].
  static final node = FocusNode(canRequestFocus: false, skipTraversal: true);

  Color _iconbg(bool focused, bool checkButton, bool isLight, bool enabled) {
    double bgA = 0.5;
    const bgH = 210.0;
    const bgS = 0.1;
    double bgL = 0.0;

    if (!enabled) {
      if (isLight) bgA = 0.125;
      bgL = focused ? 0.05 : 1 / 3;
    } else if (checkButton) {
      return isLight ? ThcColors.green : ThcColors.zaHando;
    }

    return HSLColor.fromAHSL(bgA, bgH, bgS, bgL).toColor();
  }

  static final continueIcon = appleDevice ? Icons.arrow_forward_ios : Icons.arrow_forward;

  @override
  Widget build(BuildContext context) {
    final LoginProgress(
      :focusedField,
      :fieldValues,
      :labels,
      :errorMessage,
      :showPassword,
    ) = LoginProgressTracker.of(context);
    final (username, password) = fieldValues;

    if (username == null) return const SizedBox.shrink();

    final (bool checkButton, bool focused) = switch (focusedField) {
      LoginField.top when labels.just1field => (true, true),
      LoginField.top when password == null => (false, true),
      LoginField.top => (true, passwordVisibility),
      LoginField.bottom => (true, !passwordVisibility),
      null => (labels.just1field || password != null, false),
    };

    final onPressed = passwordVisibility
        ? LoginProgressTracker.toggleShowPassword
        : LoginProgressTracker.maybeSubmit(labels, fieldValues, errorMessage != null);

    final IconData icon = switch (passwordVisibility) {
      true => showPassword ? Icons.visibility : Icons.visibility_off,
      false => checkButton ? Icons.done : continueIcon,
    };

    final brightness = Theme.of(context).brightness;

    final iconbg = _iconbg(
      focused,
      passwordVisibility ? false : checkButton,
      brightness == Brightness.light,
      passwordVisibility ? showPassword : onPressed != null,
    );

    final justUseTheDangColor = passwordVisibility && showPassword;
    final iconfg = switch ((brightness, focused)) {
      (Brightness.light, true || false) when onPressed != null => Colors.white,
      (Brightness.light, true) => Colors.white,
      (Brightness.light, false) => const Color(0xffd6e2ec),
      (Brightness.dark, _) when justUseTheDangColor => const Color(0xff2d3136),
      (Brightness.dark, true) when checkButton => Colors.black,
      (Brightness.dark, true) => ThcColors.lightContainer16,
      (Brightness.dark, false) => const Color(0xff0c0d0f),
    };

    final button = Stack(
      alignment: Alignment.center,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: iconbg, shape: BoxShape.circle),
          child: const SizedBox(width: 33, height: 33),
        ),
        IconButton(
          focusNode: node,
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: iconfg,
          ),
          onPressed: onPressed,
          icon: Icon(icon, color: iconfg),
        )
      ],
    );

    return passwordVisibility ? Positioned(top: 0, right: 0, child: button) : button;
  }
}

/// {@template start.GoBack}
/// When you tap one of the [BottomStuff] buttons,
/// this button appears in the top left to take you back where you came from.
/// {@endtemplate}
class GoBack extends StatelessWidget {
  /// {@macro start.GoBack}
  const GoBack({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginProgress(:labels) = LoginProgressTracker.of(context);
    final target = labels.back;
    return SizedBox(
      width: 48,
      height: 48,
      child: AnimatedSlide(
        offset: target == null ? const Offset(-1.5, 0) : Offset.zero,
        duration: Durations.medium1,
        curve: Curves.ease,
        child: IconButton(
          onPressed: LoginLabels.goto(target),
          icon: Icon(
            defaultTargetPlatform == TargetPlatform.iOS ? Icons.arrow_back_ios : Icons.arrow_back,
            size: 28,
          ),
        ),
      ),
    );
  }
}
