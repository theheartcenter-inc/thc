import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:thc/start/src/login_progress.dart';
import 'package:thc/utils/animation.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/clip_height.dart';

class BottomStuff extends StatefulWidget {
  /// Controls the 2 buttons that are shown at the bottom of the main UI box.
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
    final labelColor = ThcColors.of(context).outline.withOpacity(0.875);
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
      textAlign: TextAlign.center,
      child: AnimatedBuilder(animation: controller, builder: builder),
    );
  }

  static const curve = Curves.ease;

  Widget fadeSlide(double t, {required Widget child}) {
    return Transform.translate(
      offset: Offset(0, (curve.transform(t) - 1) * 10),
      child: Opacity(opacity: t, child: child),
    );
  }

  Widget builder(BuildContext context, _) {
    final t = controller.value;
    final aimedForward = controller.aimedForward;

    final tSeparator =
        aimedForward ? curve.transform(math.min(t * 2, 1)) : 1 - curve.transform(1 - t);
    final tColumns = (t - 1) * (aimedForward ? 2 : 1) + 1;

    Widget button(LoginLabels? target) {
      if (tColumns <= 0 || target == null) return const Spacer();

      const timeOffsetRatio = 7 / 8;
      final tTitle = math.min(tColumns / timeOffsetRatio, 1.0);
      final tButton = math.max((tColumns - 1) / timeOffsetRatio + 1, 0.0);

      final (:label, :text) = target.buttonData!;

      final button = FilledButton(
        onPressed: LoginLabels.goto(target),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const StyleText(letterSpacing: 1 / 3),
          ),
        ),
      );

      Widget buttonStuff = Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            fadeSlide(tTitle, child: Text(label)),
            const Spacer(),
            fadeSlide(tButton, child: button),
          ],
        ),
      );

      if (!aimedForward) {
        buttonStuff = ClipHeight(childHeight: 88, child: buttonStuff);
      }

      return Expanded(child: buttonStuff);
    }

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
                color: ThcColors.of(context).onSurfaceVariant,
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
