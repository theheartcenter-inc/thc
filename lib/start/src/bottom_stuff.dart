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

    final LoginProgress(:method, :fieldValues) = LoginProgressTracker.of(context);
    final twoFields = fieldValues.$2 != null;
    final colors = context.colorScheme;

    final button1 = switch (method) {
      LoginMethod.choosePassword => null,
      LoginMethod.idName => twoFields ? LoginMethod.signIn : LoginMethod.noID,
      LoginMethod.signIn || LoginMethod.noID => LoginMethod.idName,
    };

    final button2 = switch (method) {
      LoginMethod.choosePassword => null,
      LoginMethod.signIn => LoginMethod.noID,
      LoginMethod.idName || LoginMethod.noID => LoginMethod.signIn,
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
                null || LoginMethod.choosePassword => 'empty',
                LoginMethod.idName => 'sign up with ID',
                LoginMethod.noID => 'sign up without ID',
                LoginMethod.signIn => 'already registered?',
              },
              button: _Button(
                enabled: true,
                onPressed: () {},
                text: switch (button1) {
                  null || LoginMethod.choosePassword => 'empty',
                  LoginMethod.idName => 'return',
                  LoginMethod.noID => 'register',
                  LoginMethod.signIn => 'sign in',
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
                null || LoginMethod.choosePassword => 'empty',
                LoginMethod.idName => throw StateError('pretty sure "id/name" is always button1'),
                LoginMethod.noID => 'sign up without ID',
                LoginMethod.signIn => 'already registered?',
              },
              button: _Button(
                enabled: true,
                onPressed: () {},
                text: switch (button2) {
                  null || LoginMethod.choosePassword => 'empty',
                  LoginMethod.idName =>
                    throw StateError('pretty sure "id/name" is always button1'),
                  LoginMethod.noID => 'register',
                  LoginMethod.signIn => 'sign in',
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
