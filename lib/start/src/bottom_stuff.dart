import 'dart:math';

import 'package:flutter/material.dart';
import 'package:thc/start/src/login_progress.dart';
import 'package:thc/utils/animation.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';

class BottomStuff extends StatefulWidget {
  const BottomStuff({super.key});

  @override
  State<BottomStuff> createState() => _BottomStuffState();
}

class _BottomStuffState extends State<BottomStuff> with SingleTickerProviderStateMixin {
  LoginLabels labels = LoginLabels.withId;

  late final controller = AnimationController(
    duration: Durations.extralong4,
    reverseDuration: Durations.long2,
    vsync: this,
  )..forward();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelColor = context.colorScheme.outline.withOpacity(0.875);
    final LoginProgress(labels: labels) = LoginProgressTracker.of(context);
    final shouldShow = switch (labels) {
      LoginLabels.withId => true,
      LoginLabels.noId => false,
      LoginLabels.signIn => true,
      LoginLabels.choosePassword => false,
      LoginLabels.recovery => false,
    };
    if (shouldShow != controller.aimedForward) controller.toggle(shouldReverse: !shouldShow);
    if (shouldShow && labels != this.labels) this.labels = labels;

    return DefaultTextStyle(
      style: StyleText(weight: 600, color: labelColor),
      child: AnimatedBuilder(animation: controller, builder: builder),
    );
  }

  Widget builder(BuildContext context, _) {
    final t = controller.value;
    final aimedForward = controller.aimedForward;

    const curve = Curves.ease;
    final tSeparator = aimedForward ? curve.transform(min(t * 2, 1)) : 1 - curve.transform(1 - t);
    final tColumns = (t - 1) * (aimedForward ? 2 : 1) + 1;

    Widget fadeSlide(double t, {required Widget child}) {
      return Transform.translate(
        offset: Offset(0, (curve.transform(t) - 1) * 10),
        child: Opacity(opacity: t, child: child),
      );
    }

    Widget button(LoginLabels? target) {
      if (tColumns <= 0 || target == null) return const Spacer();

      const timeOffsetRatio = 7 / 8;
      final tTitle = min(tColumns / timeOffsetRatio, 1.0);
      final tButton = max((tColumns - 1) / timeOffsetRatio + 1, 0.0);

      final (:label, :text) = target.buttonData!;

      final title = Text(label, textAlign: TextAlign.center);

      final Widget button = Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            fadeSlide(tTitle, child: title),
            const Spacer(),
            fadeSlide(
              tButton,
              child: _Button(
                enabled: true,
                onPressed: LoginLabels.goto(target),
                text: text,
              ),
            ),
          ],
        ),
      );

      if (aimedForward) return Expanded(child: button);

      return Expanded(
        child: LayoutBuilder(builder: (context, constraints) {
          return FittedBox(
            alignment: Alignment.topCenter,
            fit: BoxFit.fitWidth,
            child: SizedBox(
              width: constraints.maxWidth,
              height: 88,
              child: button,
            ),
          );
        }),
      );
    }

    final colors = context.colorScheme;

    final (button1, button2) = labels.otherOptions!;

    return Padding(
      padding: EdgeInsets.only(top: 20 * tSeparator),
      child: SizedBox(
        height: 88 * tSeparator,
        child: Row(
          children: [
            button(button1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ColoredBox(
                color: colors.onSurfaceVariant,
                child: const SizedBox(width: 1, height: double.infinity),
              ),
            ),
            button(button2),
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
          style: const StyleText(letterSpacing: 1 / 3),
        ),
      ),
    );
  }
}
