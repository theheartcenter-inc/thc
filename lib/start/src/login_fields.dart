import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thc/start/src/bottom_stuff.dart';
import 'package:thc/start/src/progress_tracker.dart';
import 'package:thc/start/src/start_theme.dart';
import 'package:thc/start/src/za_hando.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/enum_widget.dart';

enum LoginField with StatelessEnum {
  top,
  bottom;

  FocusNode get node => switch (this) { top => nodes.$1, bottom => nodes.$2 };
  static final nodes = (FocusNode(), FocusNode());
  Future<void> listener() async {
    if (node.hasFocus) {
      LoginProgressTracker.update(focusedField: this);
      return;
    }
    await Future.delayed(const Duration(milliseconds: 50));
    LoginProgressTracker.unfocus(this);
  }

  void newVal(String value) {
    final current = LoginProgressTracker.readState.fieldValues;
    LoginProgressTracker.update(
      mismatch: false,
      fieldValues: switch (this) {
        top => (value, current.$2),
        bottom => (current.$1, value),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final LoginProgress(
      :fieldState,
      :focusedField,
      :animation,
    ) = LoginProgressTracker.of(context);

    final showBottom = animation >= AnimationProgress.showBottom;
    final colors = context.colorScheme;
    final focused = focusedField == this;
    final cursorColor = context.lightDark(ThcColors.green67, Colors.black);
    final blackHint = focused && colors.brightness == Brightness.dark;

    return TextField(
      focusNode: node,
      cursorColor: cursorColor,
      decoration: InputDecoration(
        border: InputBorder.none,
        hoverColor: Colors.transparent,
        fillColor: context
            .lightDark(Colors.white, StartColors.lightContainer)
            .withOpacity(focused ? 0.5 : 0),
        filled: true,
        hintText: switch ((this, fieldState)) {
          _ when !(showBottom || focusedField == LoginField.top) => null,
          (top, LoginFieldState.idName) => 'user ID',
          (top, LoginFieldState.noID) => 'email address',
          (top, LoginFieldState.signIn) => 'user ID or email',
          (top, LoginFieldState.choosePassword) => 'choose a password',
          (bottom, LoginFieldState.idName) => 'First and Last name',
          (bottom, LoginFieldState.noID) =>
            throw StateError('there should only be 1 email field'),
          (bottom, LoginFieldState.signIn) => 'password',
          (bottom, LoginFieldState.choosePassword) => 're-type your password',
        },
        hintStyle: TextStyle(color: blackHint ? Colors.black : colors.outline),
      ),
      onChanged: newVal,
      onSubmitted: LoginProgressTracker.maybeSubmit(),
    );
  }
}

class LoginFields extends StatelessWidget {
  const LoginFields({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginProgress(:animation, :fieldValues, :mismatch) = LoginProgressTracker.of(context);
    final twoFields = fieldValues.$2 != null;

    final colors = context.colorScheme;

    final expandText = animation >= AnimationProgress.collapseHand;
    final showBottom = animation >= AnimationProgress.showBottom;

    late final startButton = TextButton(
      onPressed: animate,
      child: AnimatedOpacity(
        duration: Durations.extralong4,
        opacity: expandText ? 0 : 1,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.only(bottom: 3),
            child: Text(
              'start',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: ThcColors.green,
              ),
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
              child: Column(
                children: [
                  LoginField.top,
                  if (twoFields) LoginField.bottom,
                ],
              ),
            ),
          ),
          Positioned.fill(child: showBottom ? const SizedBox.shrink() : startButton),
          const _Button(),
        ],
      ),
    );

    return Column(
      children: [
        fancyField,
        AnimatedSize(
          duration: Durations.medium1,
          curve: Curves.ease,
          child: mismatch
              ? const Text(
                  'check the above fields and try again.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Color(0xffc00000),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        const SizedBox(height: 8),
        if (showBottom) const BottomStuff(),
      ],
    );
  }
}

class _Button extends StatelessWidget {
  const _Button();

  Color _iconbg(bool focused, bool buttonIsGreen, bool isLight, bool disabled) {
    double bgA = 1.0;
    double bgH = 220.0;
    double bgS = 0.1;
    double bgL = 0.0;

    if (buttonIsGreen) {
      bgH = 120.0;
      bgS = 1 / 3;
      bgL = isLight ? 0.7 : 0.75;
    } else if (disabled) {
      bgA = isLight ? 0.125 : 0.5;
      bgL = focused ? 0.05 : 0.45;
    } else if (isLight) {
      bgA = 0.5;
    }

    return HSLColor.fromAHSL(bgA, bgH, bgS, bgL).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final LoginProgress(:focusedField, :fieldValues) = LoginProgressTracker.of(context);
    final (username, password) = fieldValues;
    final twoFields = password != null;

    if (username == null) return const SizedBox.shrink();

    final IconData icon;
    if (twoFields) {
      icon = Icons.done;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      icon = Icons.arrow_forward_ios;
    } else {
      icon = Icons.arrow_forward;
    }

    final focused = switch (focusedField) {
      LoginField.top => !twoFields,
      LoginField.bottom => true,
      null => false,
    };
    final onPressed = LoginProgressTracker.maybeSubmit(fieldValues);
    final buttonIsGreen = twoFields && onPressed != null;

    final brightness = context.theme.brightness;

    final iconbg = _iconbg(
      focused,
      buttonIsGreen,
      brightness == Brightness.light,
      onPressed == null,
    );

    final Color iconfg = switch ((brightness, focused)) {
      (Brightness.light, true) => Colors.white,
      (Brightness.light, false) => const Color(0xffd6e2ec),
      (Brightness.dark, true) when !buttonIsGreen => const Color(0xff6a727a),
      (Brightness.dark, true || false) => const Color(0xff0c0d0f),
    };
    return Stack(
      alignment: Alignment.center,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(color: iconbg, shape: BoxShape.circle),
          child: const SizedBox(width: 33, height: 33),
        ),
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: iconfg,
          ),
          onPressed: onPressed,
          icon: Icon(icon, color: iconfg),
        )
      ],
    );
  }
}
