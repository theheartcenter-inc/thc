import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/start/src/bottom_stuff.dart';
import 'package:thc/start/src/login_progress.dart';
import 'package:thc/start/src/start_theme.dart';
import 'package:thc/start/src/za_hando.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/enum_widget.dart';
import 'package:thc/utils/widgets/lerpy_hero.dart';

extension LoginFieldStuff<T> on (T, T) {
  T get(LoginField field) => switch (field) {
        LoginField.top => $1,
        LoginField.bottom => $2,
      };
}

enum LoginField with StatelessEnum {
  top,
  bottom;

  static final controllers = (TextEditingController(), TextEditingController());
  static final nodes = (FocusNode(), FocusNode());

  TextEditingController get controller => controllers.get(this);
  FocusNode get node => nodes.get(this);

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

    final colors = context.colorScheme;
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
            ? context.lightDark(Colors.white54, StartColors.lightContainer16)
            : Colors.transparent,
        filled: true,
        hintText: hintText,
        hintStyle: StyleText(color: blackHint ? Colors.black : colors.outline),
      ),
      obscureText: !(this == top && showPassword) && (hintText?.contains('password') ?? false),
      onChanged: newVal,
      onSubmitted: LoginProgressTracker.maybeSubmit(),
    );

    if (this == top) return textField;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const height = 48.0;
        return AnimatedContainer(
          duration: Durations.medium1,
          curve: Curves.ease,
          height: fieldValues.$2 == null || labels.just1field ? 0 : height,
          width: width,
          child: FittedBox(
            alignment: Alignment.topCenter,
            fit: BoxFit.fitWidth,
            child: SizedBox(width: width, height: height, child: textField),
          ),
        );
      },
    );
  }
}

class LoginFields extends StatelessWidget {
  const LoginFields({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginProgress(
      :animation,
      :labels,
      :fieldValues,
      :errorMessage,
    ) = LoginProgressTracker.of(context);

    final colors = context.colorScheme;

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
            const _TextFieldButton.passwordVisibility()
          else if (labels.signingIn && kDebugMode)
            const _TextFieldButton.autofill(),
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

enum _TextFieldButtonType { submit, showPassword, autofill }

class _TextFieldButton extends StatelessWidget {
  const _TextFieldButton() : type = _TextFieldButtonType.submit;
  const _TextFieldButton.passwordVisibility() : type = _TextFieldButtonType.showPassword;
  const _TextFieldButton.autofill() : type = _TextFieldButtonType.autofill;

  final _TextFieldButtonType type;
  static final node = FocusNode(canRequestFocus: false, skipTraversal: true);

  Color _iconbg(bool focused, bool checkButton, bool isLight, bool enabled) {
    double bgA = 1.0;
    const bgH = 210.0;
    const bgS = 0.1;
    double bgL = 0.0;

    if (!enabled) {
      bgA = isLight ? 0.125 : 0.5;
      bgL = focused ? 0.05 : 1 / 3;
    } else if (checkButton) {
      return isLight ? ThcColors.green : StartColors.zaHando;
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
      :labels,
      :errorMessage,
      :showPassword,
    ) = LoginProgressTracker.of(context);
    final (username, password) = fieldValues;

    if (username == null) return const SizedBox.shrink();

    final bool submitButton = type == _TextFieldButtonType.submit;
    final bool autofill = type == _TextFieldButtonType.autofill;

    final (bool checkButton, bool focused) = switch (focusedField) {
      LoginField.top when labels.just1field => (true, true),
      LoginField.top when password == null => (false, true),
      LoginField.top => (true, !submitButton),
      LoginField.bottom => (true, submitButton),
      null => (labels.just1field || password != null, false),
    };

    final onPressed = switch (type) {
      _TextFieldButtonType.submit =>
        LoginProgressTracker.maybeSubmit(labels, fieldValues, errorMessage != null),
      _TextFieldButtonType.showPassword => LoginProgressTracker.toggleShowPassword,
      _TextFieldButtonType.autofill => () {}, // unused
    };

    final IconData icon;
    switch (type) {
      case _TextFieldButtonType.submit:
        if (checkButton) {
          icon = Icons.done;
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          icon = Icons.arrow_forward_ios;
        } else {
          icon = Icons.arrow_forward;
        }

      case _TextFieldButtonType.showPassword:
        icon = showPassword ? Icons.visibility : Icons.visibility_off;

      case _TextFieldButtonType.autofill:
        icon = Icons.build;
    }

    final brightness = context.theme.brightness;

    final iconbg = _iconbg(
      focused,
      submitButton ? checkButton : false,
      brightness == Brightness.light,
      switch (type) {
        _TextFieldButtonType.submit => onPressed != null,
        _TextFieldButtonType.showPassword => showPassword,
        _TextFieldButtonType.autofill => true,
      },
    );

    final Color iconfg = switch ((brightness, focused)) {
      (Brightness.light, true || false) when onPressed != null => Colors.white,
      (Brightness.light, true) => Colors.white,
      (Brightness.light, false) => const Color(0xffd6e2ec),
      (Brightness.dark, _) when autofill || !submitButton && showPassword =>
        const Color(0xff2d3136),
      (Brightness.dark, true) when checkButton => Colors.black,
      (Brightness.dark, true) => StartColors.lightContainer16,
      (Brightness.dark, false) => const Color(0xff0c0d0f),
    };

    if (type == _TextFieldButtonType.autofill) {
      final theme = context.theme;
      final colors = theme.colorScheme;
      final themeData = theme.copyWith(
        colorScheme: colors.copyWith(surface: iconbg, onSurface: iconfg),
      );
      return Positioned(
        top: 0,
        right: 0,
        child: Theme(
          data: themeData,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox.square(
                dimension: 33,
                child: _AutofillBackground(),
              ),
              IconButton(
                focusNode: node,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: colors.onSurface,
                ),
                onPressed: () {
                  navigator.showDialog(const AutofillMenu());
                },
                icon: const _AutofillIcon(),
              )
            ],
          ),
        ),
      );
    }

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

    return submitButton ? button : Positioned(top: 0, right: 0, child: button);
  }
}

class GoBack extends StatelessWidget {
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

class AutofillMenu extends StatelessWidget {
  const AutofillMenu() : super(key: Nav.lerpy);

  static const width = 300.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        child: StartTheme(
          child: Builder(builder: _builder),
        ),
      ),
    );
  }

  Widget _builder(BuildContext context) {
    final bool isLight = context.theme.brightness == Brightness.light;
    final buttons = [
      for (final userType in UserType.values)
        FilledButton(
          onPressed: () {
            navigator.pop();
            final id = userType.testId;
            LoginProgressTracker.update(fieldValues: (id, id));
            for (final field in LoginField.values) {
              field.controller.text = id;
            }
          },
          style: FilledButton.styleFrom(
            shape: const StadiumBorder(),
            backgroundColor: StartColors.bg,
            foregroundColor: context.colorScheme.surface,
            padding: EdgeInsets.zero,
            visualDensity: const VisualDensity(vertical: 1),
          ),
          child: SizedBox(
            width: 150,
            child: Text(
              '$userType',
              textAlign: TextAlign.center,
              style: StyleText.mono(
                weight: isLight ? 500 : 700,
                color: isLight ? null : Colors.black,
              ),
            ),
          ),
        ),
    ];

    final title = _AutofillIcon(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(children: buttons),
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: _AutofillBackground()),
          title,
        ],
      ),
    );
  }
}

abstract class _SmoothColor extends LerpyHero<Color> {
  const _SmoothColor({required super.tag, super.child});

  @override
  Color lerp(Color a, Color b, double t, HeroFlightDirection direction) => Color.lerp(a, b, t)!;
}

class _AutofillBackground extends _SmoothColor {
  const _AutofillBackground() : super(tag: 'autofill background');

  @override
  Color fromContext(BuildContext context) {
    return context.lightDark(StartColors.lightContainer, Colors.black);
  }

  @override
  Widget builder(BuildContext context, Color value, Widget? child) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: value,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
    );
  }
}

class _AutofillIcon extends _SmoothColor {
  const _AutofillIcon({super.child}) : super(tag: 'autofill icon');

  @override
  Color fromContext(BuildContext context) => context.colorScheme.outline;

  @override
  Widget builder(BuildContext context, Color value, Widget? child) {
    final icon = Icon(Icons.build, color: value, size: 20);
    if (child == null) return icon;
    return DefaultTextStyle(
      style: context.theme.textTheme.bodyMedium!,
      softWrap: false,
      overflow: TextOverflow.fade,
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 24),
              SizedBox(
                width: min(110, constraints.maxWidth),
                child: Row(
                  children: [
                    icon,
                    const Spacer(),
                    Expanded(
                      flex: 20,
                      child: Text(
                        'Autofill',
                        style: StyleText(
                          size: 24,
                          weight: 550,
                          color: context.colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: constraints.maxWidth,
                child: FittedBox(
                  child: SizedBox(width: AutofillMenu.width - 50, child: child),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
