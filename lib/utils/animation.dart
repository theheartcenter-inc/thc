import 'package:flutter/animation.dart';

extension ToggleController on Animation {
  bool get aimedForward => switch (status) {
        AnimationStatus.forward || AnimationStatus.completed => true,
        AnimationStatus.reverse || AnimationStatus.dismissed => false,
      };
  void toggle({bool? shouldReverse, double? from}) {
    final animation = this;
    if (animation is! AnimationController) throw UnimplementedError();
    shouldReverse ?? aimedForward ? animation.reverse(from: from) : animation.forward(from: from);
  }
}
