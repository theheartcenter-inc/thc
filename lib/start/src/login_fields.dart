import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thc/start/src/bottom_stuff.dart';
import 'package:thc/start/src/progress_tracker.dart';
import 'package:thc/start/src/start_theme.dart';
import 'package:thc/start/src/za_hando.dart';
import 'package:thc/utils/style_text.dart';
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

  void newVal(String? value) {
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
      :fieldValues,
    ) = LoginProgressTracker.of(context);

    final colors = context.colorScheme;
    final focused = focusedField == this;
    final cursorColor = context.lightDark(ThcColors.green67, Colors.black);
    final blackHint = focused && colors.brightness == Brightness.dark;

    final field = TextField(
      focusNode: node,
      cursorColor: cursorColor,
      decoration: InputDecoration(
        border: InputBorder.none,
        hoverColor: Colors.transparent,
        fillColor: focused
            ? context.lightDark(Colors.white54, StartColors.lightContainer16)
            : Colors.transparent,
        filled: true,
        hintText: animation >= AnimationProgress.showBottom || focusedField != null
            ? switch (this) { top => fieldState.topHint, bottom => fieldState.bottomHint }
            : null,
        hintStyle: StyleText(color: blackHint ? Colors.black : colors.outline),
      ),
      onChanged: newVal,
      onSubmitted: LoginProgressTracker.maybeSubmit(),
    );

    if (this == top) return field;

    return LayoutBuilder(
      builder: (context, constraints) => AnimatedContainer(
        duration: Durations.medium1,
        curve: Curves.ease,
        height: fieldValues.$2 == null || fieldState.just1field ? 0 : 48,
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: SizedBox(width: constraints.maxWidth, child: field),
        ),
      ),
    );
  }
}

class LoginFields extends StatelessWidget {
  const LoginFields({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginProgress(:animation, :fieldState, :mismatch) = LoginProgressTracker.of(context);

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
          const _Button(),
        ],
      ),
    );

    final Widget helpText;
    if (mismatch) {
      helpText = Text(
        'check the above field${fieldState.just1field ? "" : "s"} and try again.',
        textAlign: TextAlign.center,
        style: const StyleText(size: 12, weight: 600, color: Color(0xffc00000)),
      );
    } else if (fieldState == LoginFieldState.recovery) {
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

class _Button extends StatelessWidget {
  const _Button();

  Color _iconbg(bool focused, bool checkButton, bool isLight, bool disabled) {
    double bgA = 1.0;
    double bgH = 210.0;
    double bgS = 0.1;
    double bgL = 0.0;

    if (disabled) {
      bgA = isLight ? 0.125 : 0.5;
      bgL = focused ? 0.05 : 1 / 3;
    } else if (checkButton) {
      bgH = 120.0;
      bgS = 1 / 3;
      bgL = isLight ? 0.7 : 0.75;
    } else if (isLight) {
      bgA = 0.5;
    }

    return HSLColor.fromAHSL(bgA, bgH, bgS, bgL).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final LoginProgress(
      :focusedField,
      :fieldValues,
      :fieldState,
      :mismatch,
    ) = LoginProgressTracker.of(context);
    final (username, password) = fieldValues;

    if (username == null) return const SizedBox.shrink();

    final (bool checkButton, bool focused) = switch (focusedField) {
      LoginField.top when fieldState.just1field => (true, true),
      LoginField.top when password == null => (false, true),
      LoginField.top => (true, false),
      LoginField.bottom => (true, true),
      null => (fieldState.just1field || password != null, false),
    };

    final onPressed = LoginProgressTracker.maybeSubmit(fieldValues, mismatch);

    final IconData icon;
    if (checkButton) {
      icon = Icons.done;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      icon = Icons.arrow_forward_ios;
    } else {
      icon = Icons.arrow_forward;
    }

    final brightness = context.theme.brightness;

    final iconbg = _iconbg(
      focused,
      checkButton,
      brightness == Brightness.light,
      onPressed == null,
    );

    final Color iconfg = switch ((brightness, focused)) {
      (Brightness.light, true) => Colors.white,
      (Brightness.light, false) => const Color(0xffd6e2ec),
      (Brightness.dark, true) when !checkButton => StartColors.lightContainer16,
      (Brightness.dark, true) => Colors.black,
      (Brightness.dark, false) => const Color(0xff0c0d0f),
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

class GoBack extends StatelessWidget {
  const GoBack({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginProgress(:fieldState) = LoginProgressTracker.of(context);
    final target = fieldState.back;
    return SizedBox(
      width: 48,
      height: 48,
      child: AnimatedSlide(
        offset: target == null ? const Offset(-1.5, 0) : Offset.zero,
        duration: Durations.medium1,
        curve: Curves.ease,
        child: IconButton(
          onPressed: LoginFieldState.goto(target),
          icon: Icon(
            defaultTargetPlatform == TargetPlatform.iOS ? Icons.arrow_back_ios : Icons.arrow_back,
            size: 28,
          ),
        ),
      ),
    );
  }
}
