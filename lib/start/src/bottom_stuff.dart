import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:thc/start/src/login_progress.dart';
import 'package:thc/utils/bloc.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/clip_height.dart';

class BottomStuff extends HookWidget {
  /// Controls the 2 buttons that are shown at the bottom of the main UI box.
  const BottomStuff({super.key});

  static const curve = Curves.ease;

  static Widget fadeSlide(double t, {required Widget child}) {
    return Transform.translate(
      offset: Offset(0, (curve.transform(t) - 1) * 10),
      child: Opacity(opacity: t, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginLabels = useState(LoginLabels.withId);
    final controller = useAnimationController(
      duration: Durations.extralong4,
      reverseDuration: Durations.long2,
    );
    useOnce(controller.forward);

    final ColorScheme colors = ThcColors.of(context);
    final LoginLabels labels = LoginProgressTracker.labelsOf(context);
    final shouldShow = switch (labels) {
      LoginLabels.withId => true,
      LoginLabels.noId => false,
      LoginLabels.signIn => true,
      LoginLabels.choosePassword => false,
      LoginLabels.recovery => false,
    };

    final bool forwardOrComplete = controller.isForwardOrCompleted;
    if (shouldShow != forwardOrComplete) controller.toggle(shouldReverse: !shouldShow);
    if (shouldShow && labels != loginLabels.value) loginLabels.value = labels;

    return DefaultTextStyle(
      style: StyleText(weight: 600, color: colors.outline.withOpacity(0.875)),
      textAlign: TextAlign.center,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final bool forwardOrComplete = controller.isForwardOrCompleted;
          final double t = controller.value;

          final tColumns = (t - 1) * (forwardOrComplete ? 2 : 1) + 1;
          final tSeparator = forwardOrComplete
              ? curve.transform(math.min(t * 2, 1))
              : 1 - curve.transform(1 - t);

          const timeOffsetRatio = 7 / 8;
          late final tTitle = math.min(tColumns / timeOffsetRatio, 1.0);
          late final tButton = math.max((tColumns - 1) / timeOffsetRatio + 1, 0.0);

          Widget button(LoginLabels? target) {
            if (tColumns <= 0 || target == null) return const Spacer();

            final (:label, :text) = target.buttonData!;

            const spaced = StyleText(letterSpacing: 1 / 3);
            final button = FilledButton(
              onPressed: LoginLabels.goto(target),
              child: SizedBox(
                width: double.infinity,
                child: Text(text, style: spaced, textAlign: TextAlign.center),
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

            if (!forwardOrComplete) {
              buttonStuff = ClipHeight(childHeight: 88, child: buttonStuff);
            }
            return Expanded(child: buttonStuff);
          }

          final (button1, button2) = loginLabels.value.otherOptions!;

          return Padding(
            padding: EdgeInsets.only(top: 20 * tSeparator),
            child: SizedBox(
              height: 88 * tSeparator,
              child: Row(children: [button(button1), child!, button(button2)]),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ColoredBox(
            color: colors.onSurfaceVariant,
            child: const SizedBox(width: 1, height: double.infinity),
          ),
        ),
      ),
    );
  }
}
