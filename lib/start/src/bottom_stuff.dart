import 'dart:math';

import 'package:flutter/material.dart';
import 'package:thc/start/src/progress_tracker.dart';
import 'package:thc/start/src/start_theme.dart';
import 'package:thc/start/src/za_hando.dart';

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

    final LoginProgress(:method, :twoLoginFields) = LoginProgressTracker.of(context);

    final button1 = switch (method) {
      LoginMethod.idName => twoLoginFields ? LoginMethod.signIn : LoginMethod.noID,
      LoginMethod.signIn || LoginMethod.noID => LoginMethod.idName,
    };

    final button2 = switch (method) {
      _ when twoLoginFields => null,
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
                LoginMethod.idName => 'sign up with ID',
                LoginMethod.noID => 'sign up without ID',
                LoginMethod.signIn => 'already registered?',
              },
              button: _Button(
                enabled: true,
                onPressed: () {},
                text: switch (button1) {
                  LoginMethod.idName => 'return',
                  LoginMethod.noID => 'register',
                  LoginMethod.signIn => 'sign in',
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: ColoredBox(
                color: StartColors.bg12,
                child: SizedBox(width: 1, height: double.infinity),
              ),
            ),
            _SignInOptions(
              tColumns,
              title: switch (button2) {
                null => 'empty',
                LoginMethod.idName => throw StateError('pretty sure "id/name" is always button1'),
                LoginMethod.noID => 'sign up without ID',
                LoginMethod.signIn => 'already registered?',
              },
              button: _Button(
                enabled: true,
                onPressed: () {},
                text: switch (button2) {
                  null => 'empty',
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

    final title = Align(
      alignment: Alignment.topCenter,
      child: Text(
        this.title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w600),
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
      style: FilledButton.styleFrom(
        foregroundColor: StartColors.dullGreen,
      ),
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
