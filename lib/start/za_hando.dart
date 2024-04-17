/// {@template za_hando}
/// ### 『 ZA HANDO 』
///
/// ![『 ZA HANDO 』](https://static.jojowiki.com/images/thumb/5/59/latest/20201229074308/Za_hando.jpg/400px-Za_hando.jpg)
/// {@endtemplate}
library;

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:thc/start/login_fields.dart';
import 'package:thc/utils/svg_parsing/svg_paths.dart';
import 'package:thc/utils/widgets/hand_vector.dart';

/// {@macro za_hando}
class ZaHando extends StatelessWidget {
  /// {@macro za_hando}
  const ZaHando({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: TweenAnimationBuilder(
        duration: duration,
        tween: Tween(begin: 0.0, end: 1.0),
        builder: builder,
        child: const LoginFields(),
      ),
    );
  }

  static const handSize = Size(600, 800);
  static const sunSize = 225.0;
  static const sunPadding = 20.0;
  static const duration = Duration(seconds: 5);

  Widget builder(BuildContext _, double t, Widget? child) {
    final t2 = t * t;
    final t5 = t2 * t2 * t;
    final t10 = t5 * t5;
    final backgroundGradient = t < 2 / 3;

    final handColor = HSVColor.fromAHSV(1.0, 180 - t * 60, 1 - t * 0.75, t * 0.8);

    final tSun = Curves.easeOutSine.transform(t);
    final sunCenter = HSVColor.fromAHSV(1, tSun * 30 + 30, 1, (tSun + 1) / 2);
    final sunOuter = sunCenter.withHue(tSun * 30 + 20);
    final sunBorder = const Color(0xffffcc00).withOpacity(t10);
    final sunGlow = const Color(0xfffff0e0).withOpacity(1.4 * (t2 - t10));

    final tSunrise = Curves.easeOutSine.transform(min(t * 1.25, 1));
    final sunOffset = Offset(0, (sunSize + sunPadding * 2.5) * (1 - tSunrise));

    final tContainer = max(3 * (t - 1) + 1, 0.0);
    final containerColor = const Color(0xe0e0f0ff).withOpacity(tContainer * 7 / 8);

    final tScale = Curves.easeOutExpo.transform(tContainer);
    final scale = 20 * (1 - tScale) + 1.0;

    final innerHand = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: 1.2,
          child: _FadeIn.text(t, 'THE HEART', const Color(0x6060a060)),
        ),
        Transform.translate(
          offset: sunOffset,
          child: Padding(
            padding: const EdgeInsets.all(sunPadding),
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
              child: SizedBox(
                width: sunSize,
                height: sunSize,
                child: Center(
                  child: Transform.scale(
                    scaleY: 1.1,
                    child: _FadeIn.text(t, 'CENTER', const Color(0x20ff0000)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    final zaHando = Center(
      child: LayoutBuilder(
        builder: (context, constraints) => Container(
          margin: const EdgeInsets.all(25),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: constraints.maxHeight - 400),
                child: Padding(
                  padding: const EdgeInsets.all(25).copyWith(top: 0),
                  child: FittedBox(
                    child: Stack(
                      children: [
                        if (backgroundGradient)
                          SizedBox.fromSize(size: handSize)
                        else
                          Transform.scale(
                            scale: scale,
                            child: CustomPaint(
                              size: handSize,
                              painter: SvgPainter(
                                color: handColor.toColor(),
                                svgPath: SvgPaths.thcLogo,
                              ),
                              child: SizedBox.fromSize(size: handSize),
                            ),
                          ),
                        Positioned.fill(
                          child: ClipRect(
                            child: Align(
                              alignment: const Alignment(0, 0.8),
                              child: innerHand,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _FadeIn(t, child: child),
            ],
          ),
        ),
      ),
    );
    if (!backgroundGradient) return zaHando;

    final tHorizon = (t * 2 - 1 / 3).clamp(0.0, 1.0);
    late final handHorizon = HSVColor.lerp(
      HSVColor.fromAHSV(1.0, 0, 1 - tHorizon * 0.75, tHorizon * 0.8),
      handColor,
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
              colors: [handColor.toColor(), if (!kIsWeb) handHorizon.toColor()],
            ),
          ),
          child: const SizedBox.expand(),
        ),
        zaHando,
      ],
    );
  }
}

class _FadeIn extends StatelessWidget {
  const _FadeIn(this.t, {required this.child});

  _FadeIn.text(this.t, String text, Color color) : child = Text(text, style: _style(color));

  static TextStyle _style(Color color) =>
      const TextStyle(fontSize: 48, fontWeight: FontWeight.bold).copyWith(color: color);

  final double t;
  final Widget? child;
  static const duration = Duration(milliseconds: 1250);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: t.floorToDouble(),
      duration: duration,
      curve: Curves.easeOut,
      child: child,
    );
  }
}
