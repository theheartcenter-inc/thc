import 'package:flutter/animation.dart';

extension ToggleController on Animation {
  bool get aimedForward => switch (status) {
        AnimationStatus.forward || AnimationStatus.completed => true,
        AnimationStatus.reverse || AnimationStatus.dismissed => false,
      };

  TickerFuture toggle({bool? shouldReverse, double? from}) {
    final animation = this;
    if (animation is! AnimationController) throw UnimplementedError();
    return (shouldReverse ?? aimedForward)
        ? animation.reverse(from: from)
        : animation.forward(from: from);
  }
}
