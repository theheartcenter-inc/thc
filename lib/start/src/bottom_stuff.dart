import 'dart:math';

import 'package:flutter/material.dart';
import 'package:thc/start/src/progress_tracker.dart';
import 'package:thc/start/src/za_hando.dart';
import 'package:thc/utils/theme.dart';

class BottomStuff extends StatelessWidget {
  const BottomStuff({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      duration: ZaHando.shrinkDuration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: builder,
    );
  }

  Widget builder(BuildContext context, double t, [_]) {
    const tLineRatio = 0.5;
    final tLine = Curves.ease.transform(min(t / tLineRatio, 1));
    final tColumns = (t - 1) / (1 - tLineRatio) + 1;

    final LoginProgress(:fieldState, :fieldValues) = LoginProgressTracker.of(context);
    final twoFields = fieldValues.$2 != null;
    final colors = context.colorScheme;

    final button1 = switch (fieldState) {
      LoginFieldState.choosePassword => null,
      LoginFieldState.idName => twoFields ? LoginFieldState.signIn : LoginFieldState.noID,
      LoginFieldState.signIn || LoginFieldState.noID => LoginFieldState.idName,
    };

    final button2 = switch (fieldState) {
      LoginFieldState.choosePassword => null,
      LoginFieldState.signIn => LoginFieldState.noID,
      LoginFieldState.idName || LoginFieldState.noID => LoginFieldState.signIn,
    };

    return Padding(
      padding: EdgeInsets.only(top: 10 * tLine),
      child: SizedBox(
        height: 88 * tLine,
        child: Row(
          children: [
            _SignInOptions(
              tColumns,
              title: switch (button1) {
                null || LoginFieldState.choosePassword => 'empty',
                LoginFieldState.idName => 'sign up with ID',
                LoginFieldState.noID => 'sign up without ID',
                LoginFieldState.signIn => 'already registered?',
              },
              button: _Button(
                enabled: true,
                onPressed: () {},
                text: switch (button1) {
                  null || LoginFieldState.choosePassword => 'empty',
                  LoginFieldState.idName => 'return',
                  LoginFieldState.noID => 'register',
                  LoginFieldState.signIn => 'sign in',
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ColoredBox(
                color: colors.onSurfaceVariant,
                child: const SizedBox(width: 1, height: double.infinity),
              ),
            ),
            _SignInOptions(
              tColumns,
              title: switch (button2) {
                null || LoginFieldState.choosePassword => 'empty',
                LoginFieldState.idName =>
                  throw StateError('pretty sure "id/name" is always button1'),
                LoginFieldState.noID => 'sign up without ID',
                LoginFieldState.signIn => 'already registered?',
              },
              button: _Button(
                enabled: true,
                onPressed: () {},
                text: switch (button2) {
                  null || LoginFieldState.choosePassword => 'empty',
                  LoginFieldState.idName =>
                    throw StateError('pretty sure "id/name" is always button1'),
                  LoginFieldState.noID => 'register',
                  LoginFieldState.signIn => 'sign in',
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignInOptions extends StatelessWidget {
  const _SignInOptions(this.t, {required this.title, required this.button});
  final double t;
  final String title;
  final _Button button;

  Widget fadeSlide(double t, {required Widget child}) {
    return Transform.translate(
      offset: Offset(0, (Curves.ease.transform(t) - 1) * 10),
      child: Opacity(opacity: t, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (t < 0) return const Spacer();

    const timeOffsetRatio = 7 / 8;
    final tTitle = min(t / timeOffsetRatio, 1.0);
    final tButton = max((t - 1) / timeOffsetRatio + 1, 0.0);
    final colors = context.colorScheme;

    final title = Align(
      alignment: Alignment.topCenter,
      child: Text(
        this.title,
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.w600, color: colors.outline),
      ),
    );

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: fadeSlide(tTitle, child: title)),
            fadeSlide(tButton, child: button),
          ],
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({required this.enabled, required this.onPressed, required this.text});
  final bool enabled;
  final VoidCallback? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: enabled ? onPressed : null,
      child: SizedBox(
        width: double.infinity,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(letterSpacing: 1 / 3),
        ),
      ),
    );
  }
}
