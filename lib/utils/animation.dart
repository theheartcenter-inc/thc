import 'package:flutter/animation.dart';

extension ToggleController on AnimationController {
  bool get aimedForward => switch (status) {
        AnimationStatus.forward || AnimationStatus.completed => true,
        AnimationStatus.reverse || AnimationStatus.dismissed => false,
      };
  void toggle({bool? shouldReverse, double? from}) =>
      shouldReverse ?? aimedForward ? reverse(from: from) : forward(from: from);
}
