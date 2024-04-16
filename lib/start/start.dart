import 'dart:math';

import 'package:flutter/material.dart';
import 'package:thc/utils/widgets/hand_vector.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: ZaHando(),
      ),
    );
  }
}

/// (it's a JoJo reference)
///
/// ![『 ZA HANDO 』](https://static.jojowiki.com/images/thumb/5/59/latest/20201229074308/Za_hando.jpg/400px-Za_hando.jpg)
class ZaHando extends StatelessWidget {
  const ZaHando({super.key});

  Widget _builder(_, double t, __) {
    final t2 = t * t;
    final t5 = t2 * t2 * t;
    final t10 = t5 * t5;
    final zaHando = t > 2 / 3;
    const size = Size(600, 800);

    final hand = HSVColor.fromAHSV(1.0, 180 - t * 60, 1 - t * 0.75, t * 0.8);

    final sunCenter = HSVColor.fromAHSV(1, t * 30 + 30, 1, (t + 1) / 2);
    final sunOuter = sunCenter.withHue(t * 30 + 20);
    final sunBorder = const Color(0xffffcc00).withOpacity(t10);
    final sunGlow = const Color(0xfffff0e0).withOpacity(1.4 * (t2 - t10));

    final tScale = Curves.easeOutExpo.transform(max(3 * (t - 1) + 1, 0));
    final scale = 20 * (1 - tScale) + 1.0;

    final tOffset = Curves.ease.transform(t);
    final offset = Offset(0, 500 * (1 - tOffset) - 100);

    final widget = FittedBox(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          if (zaHando)
            Transform.scale(
              key: const Key('hand'),
              scale: scale,
              child: CustomPaint(
                size: size,
                painter: SvgPainter(color: hand.toColor(), fileName: 'thc_logo'),
              ),
            )
          else
            SizedBox.fromSize(size: size),
          Transform.translate(
            key: const Key('sun'),
            offset: offset,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    sunCenter.toColor(),
                    HSVColor.lerp(sunCenter, sunOuter, 1 / 3)!.toColor(),
                    sunOuter.toColor(),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(width: 4, color: sunBorder),
                boxShadow: [BoxShadow(color: sunGlow, blurRadius: 20)],
              ),
              child: const SizedBox(width: 233, height: 233),
            ),
          ),
        ],
      ),
    );
    if (zaHando) return widget;

    final tHorizon = (t * 2 - 1 / 3).clamp(0.0, 1.0);
    final handHorizon = HSVColor.lerp(
      HSVColor.fromAHSV(1.0, 0, 1 - tHorizon * 0.75, tHorizon * 0.8),
      hand,
      tHorizon,
    )!;
    return Stack(
      alignment: Alignment.center,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [hand.toColor(), handHorizon.toColor()],
            ),
          ),
          child: const SizedBox.expand(),
        ),
        widget,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: TweenAnimationBuilder(
        duration: const Duration(seconds: 6),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: _builder,
      ),
    );
  }
}
