import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thc/start/src/bottom_stuff.dart';
import 'package:thc/start/src/login_progress.dart';
import 'package:thc/start/src/start_theme.dart';
import 'package:thc/start/src/za_hando.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/enum_widget.dart';

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

class _TextFieldButton extends StatelessWidget {
  const _TextFieldButton() : passwordVisibility = false;
  const _TextFieldButton.passwordVisibility() : passwordVisibility = true;

  final bool passwordVisibility;
  static final node = FocusNode(canRequestFocus: false, skipTraversal: true);

  Color _iconbg(bool focused, bool checkButton, bool isLight, bool enabled) {
    double bgA = 1.0;
    double bgH = 210.0;
    double bgS = 0.1;
    double bgL = 0.0;

    if (!enabled) {
      bgA = isLight ? 0.125 : 0.5;
      bgL = focused ? 0.05 : 1 / 3;
    } else if (checkButton) {
      bgH = 120.0;
      bgS = 1 / 3;
      bgL = isLight ? 0.7 : 0.63;
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

    final IconData icon;
    if (passwordVisibility) {
      icon = showPassword ? Icons.visibility : Icons.visibility_off;
    } else if (checkButton) {
      icon = Icons.done;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      icon = Icons.arrow_forward_ios;
    } else {
      icon = Icons.arrow_forward;
    }

    final brightness = context.theme.brightness;

    final iconbg = _iconbg(
      focused,
      passwordVisibility ? false : checkButton,
      brightness == Brightness.light,
      passwordVisibility ? showPassword : onPressed != null,
    );

    final Color iconfg = switch ((brightness, focused)) {
      (Brightness.light, true) => Colors.white,
      (Brightness.light, false) => const Color(0xffd6e2ec),
      (Brightness.dark, _) when passwordVisibility && showPassword => const Color(0xff2d3136),
      (Brightness.dark, true) when !checkButton => StartColors.lightContainer16,
      (Brightness.dark, true) => Colors.black,
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
