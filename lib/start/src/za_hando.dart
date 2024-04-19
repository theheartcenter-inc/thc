/// {@template za_hando}
/// ### 『 ZA HANDO 』
///
/// ![『 ZA HANDO 』](https://static.jojowiki.com/images/thumb/5/59/latest/20201229074308/Za_hando.jpg/400px-Za_hando.jpg)
/// {@endtemplate}
library;

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thc/start/src/login_fields.dart';
import 'package:thc/start/src/progress_tracker.dart';
import 'package:thc/start/src/start_theme.dart';
import 'package:thc/utils/svg_parsing/svg_paths.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/hand_vector.dart';

/// {@macro za_hando}
class ZaHando extends StatelessWidget {
  /// {@macro za_hando}
  const ZaHando({super.key});

  static const duration = Duration(seconds: 5);
  static const _shrinkMs = 1500;
  static const _shrinkDuration = Duration(milliseconds: _shrinkMs);

  static const transition = Duration(milliseconds: _shrinkMs ~/ (1 / handBounceTime));
  static const shrinkDuration = Duration(milliseconds: _shrinkMs ~/ (1 / motionRatio));

  @override
  Widget build(BuildContext context) {
    final LoginProgress(:pressedStart) = LoginProgressTracker.of(context);
    return Scaffold(
      backgroundColor: StartColors.bg,
      body: SizedBox.expand(
        child: TweenAnimationBuilder(
          key: ValueKey(pressedStart),
          duration: pressedStart ? _shrinkDuration : duration,
          tween: Tween(begin: 0.0, end: 1.0),
          builder: pressedStart ? shrinker : builder,
          child: const LoginFields(),
        ),
      ),
    );
  }

  static const _handWidth = 600.0, _handHeight = 800.0;
  static const handSize = Size(_handWidth, _handHeight);
  static const sunSize = 225.0;
  static const sunPadding = 20.0;

  Widget builder(BuildContext _, double t, Widget? child) {
    final t2 = t * t;
    final t5 = t2 * t2 * t;
    final t10 = t5 * t5;
    final backgroundGradient = t < 2 / 3;

    final handColor = HSVColor.fromAHSV(1.0, 180 - t * 60, 1 - t * 0.75, t * 0.8);

    final tSun = Curves.easeOutSine.transform(t);
    final sunCenter = HSVColor.fromAHSV(1, tSun * 30 + 30, 1, (tSun + 1) / 2);
    final sunOuter = sunCenter.withHue(tSun * 30 + 20);
    final sunBorder = Border.all(
      width: 4,
      color: SunColors.border.withOpacity(t10),
    );
    final sunGlow = BoxShadow(
      color: SunColors.glow.withOpacity(1.4 * (t2 - t10)),
      blurRadius: 20,
    );

    final tSunrise = Curves.easeOutSine.transform(min(t * 1.25, 1));
    final sunOffset = Offset(0, (sunSize + sunPadding * 2.5) * (1 - tSunrise));

    final tContainer = max(3 * (t - 1) + 1, 0.0);

    final tScale = Curves.easeOutExpo.transform(tContainer);
    final scale = 20 * (1 - tScale) + 1.0;

    final innerHand = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: 1.2,
          child: _FadeIn(
            t,
            child: const Text(
              'THE HEART',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: StartColors.dullGreen38,
              ),
            ),
          ),
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
                border: sunBorder,
                boxShadow: [
                  sunGlow,
                ],
              ),
              child: SizedBox(
                width: sunSize,
                height: sunSize,
                child: Center(
                  child: Transform.scale(
                    scaleY: 1.1,
                    child: _FadeIn(
                      t,
                      child: const Text(
                        'CENTER',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: SunColors.overlayText,
                        ),
                      ),
                    ),
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
            color: StartColors.lightContainer.withOpacity(tContainer * 7 / 8),
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
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 425),
                                child: innerHand,
                              ),
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

  static const handBounceTime = 0.25;
  static const handTotalTime = 0.5;
  static const minScale = 0.8;
  static const motionRatio = 1 - handBounceTime;

  Widget shrinker(BuildContext _, double t, Widget? child) {
    final tHand = min(t / handTotalTime, 1.0);
    final double scale = switch (tHand - handBounceTime) {
      < 0 => 1 - tHand * (1 - minScale) / handBounceTime,
      final tScale => 12 * tScale * tScale + minScale,
    };

    final tMotionLinear = max(1 + (t - 1) / motionRatio, 0.0);
    final tMotion = Curves.ease.transform(tMotionLinear);
    final fontSize = 48 - 10 * tMotion;

    final opacity = 1 - t * t;

    final innerHand = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: 1.2 - tMotion * 0.2,
          child: Text(
            'THE HEART',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Color.lerp(StartColors.dullGreen38, StartColors.bg12, t),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(sunPadding * (1 - tMotion)),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: SunColors.withOpacity(1 - tHand),
              shape: BoxShape.circle,
              border: Border.all(width: 4, color: SunColors.border.withOpacity(1 - tHand)),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: sunSize,
                minHeight: sunSize * (1 - tMotion),
              ),
              child: Center(
                child: Transform.scale(
                  scaleY: 1.1 - 0.1 * tMotion,
                  child: Text(
                    'CENTER',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Color.lerp(SunColors.overlayText, StartColors.bg12, t),
                      shadows: const [Shadow(color: StartColors.bg)],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) => Container(
          margin: const EdgeInsets.all(25),
          padding: const EdgeInsets.all(25),
          decoration: const BoxDecoration(
            color: StartColors.lightContainer,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          width: 450,
          clipBehavior: Clip.hardEdge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight - 400,
                ),
                child: Padding(
                  padding: EdgeInsets.all(25 * (1 - tMotion)).copyWith(top: 0),
                  child: FittedBox(
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        SizedBox(
                          width: _handWidth,
                          height: _handHeight * (1 - tMotion),
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Transform.scale(
                              scale: scale,
                              child: CustomPaint(
                                size: handSize,
                                painter: SvgPainter(
                                  color: ThcColors.green.withOpacity(opacity),
                                  svgPath: SvgPaths.thcLogo,
                                ),
                                child: SizedBox.fromSize(size: handSize),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: 425 * (1 - tMotion),
                            bottom: 20 * tMotion,
                          ),
                          child: innerHand,
                        ),
                        // Positioned.fill(
                        //   child: Align(
                        //     alignment: const Alignment(0, 0.8),
                        //     child: innerHand,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              child!,
            ],
          ),
        ),
      ),
    );
  }
}

class _FadeIn extends StatelessWidget {
  const _FadeIn(this.t, {required this.child});

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
