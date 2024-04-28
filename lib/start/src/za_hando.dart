/// {@template za_hando}
/// ### 『 ZA HANDO 』
///
/// ![『 ZA HANDO 』](https://static.jojowiki.com/images/thumb/5/59/latest/20201229074308/Za_hando.jpg/400px-Za_hando.jpg)
/// {@endtemplate}
library;

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thc/home/profile/choose_any_view/choose_any_view.dart';
import 'package:thc/start/src/login_fields.dart';
import 'package:thc/start/src/login_progress.dart';
import 'package:thc/start/src/start_theme.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/theme_mode_picker.dart';

/// runs when the user presses "start".
void animate() async {
  LoginProgressTracker.update(animation: AnimationProgress.pressStart);
  await Future.delayed(ZaHando.transition);
  LoginProgressTracker.update(animation: AnimationProgress.collapseHand);
  await Future.delayed(ZaHando.shrinkDuration);
  LoginField.top.node.requestFocus();
  await Future.delayed(Durations.extralong1);
  LoginProgressTracker.update(animation: AnimationProgress.showBottom);
}

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
    final LoginProgress(:animation) = LoginProgressTracker.of(context);
    final pressedStart = animation >= AnimationProgress.pressStart;

    Widget contents = TweenAnimationBuilder(
      key: ValueKey(pressedStart),
      duration: pressedStart ? _shrinkDuration : duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: pressedStart ? collapse : sunrise,
      child: const LoginFields(),
    );

    if (pressedStart) contents = _TopButtons(child: contents);

    return Scaffold(
      backgroundColor: StartColors.bg,
      body: SafeArea(child: SizedBox.expand(child: contents)),
    );
  }

  static const _handWidth = 600.0, _handHeight = 800.0;
  static const handSize = Size(_handWidth, _handHeight);
  static const sunSize = 225.0;
  static const sunPadding = 20.0;

  Widget sunrise(BuildContext context, double t, Widget? child) {
    final t2 = t * t;
    final t5 = t2 * t2 * t;
    final t10 = t5 * t5;
    final backgroundGradient = t < 2 / 3;

    final colors = context.colorScheme;
    final (tSaturation, tValue) = switch (colors.brightness) {
      Brightness.light => (1 - t * 0.75, t * 0.8),
      Brightness.dark => (1 - t * 2 / 3, t * 0.75),
    };
    final handHSV = HSVColor.fromAHSV(1.0, 180 - t * 60, tSaturation, tValue);
    final handColor = t == 1 ? colors.primary : handHSV.toColor();

    final tSun = Curves.easeOutSine.transform(t);
    final sunCenter = HSVColor.fromAHSV(1, tSun * 30 + 30, 1, (tSun + 1) / 2);
    final sunOuter = sunCenter.withHue(tSun * 30 + 20);
    final sunMid = HSVColor.lerp(sunCenter, sunOuter, 1 / 3)!;
    final sunBorder = Border.all(width: 4, color: SunColors.border.withOpacity(t10));
    final tGlow = 1.4 * (t2 - t10);
    final sunGlow = BoxShadow(color: SunColors.glow.withOpacity(tGlow), blurRadius: 20);

    final tSunrise = Curves.easeOutSine.transform(min(t * 1.25, 1));
    final sunOffset = Offset(0, (sunSize + sunPadding * 2.5) * (1 - tSunrise));

    final tContainer = max(3 * (t - 1) + 1, 0.0);

    final tScale = Curves.easeOutExpo.transform(tContainer);
    final scale = 20 * (1 - tScale) + 1.0;

    final heartText = Text('THE HEART', style: StyleText(color: colors.primaryContainer));
    const centerText = Text('CENTER', style: StyleText(color: SunColors.overlayText));

    final innerHand = DefaultTextStyle(
      style: const StyleText(size: 48, weight: 720),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(scale: 1.2, child: _FadeIn(t, child: heartText)),
          Transform.translate(
            offset: sunOffset,
            child: Padding(
              padding: const EdgeInsets.all(sunPadding),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [sunCenter.toColor(), sunMid.toColor(), sunOuter.toColor()],
                  ),
                  shape: BoxShape.circle,
                  border: sunBorder,
                  boxShadow: [sunGlow],
                ),
                child: SizedBox(
                  width: sunSize,
                  height: sunSize,
                  child: Center(
                    child: Transform.scale(
                      scaleY: 1.1,
                      child: _FadeIn(t, child: centerText),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final zaHando = LayoutBuilder(
      builder: (context, constraints) => Container(
        margin: const EdgeInsets.all(25),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: colors.surface.withOpacity(tContainer),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: constraints.maxHeight - 275),
              child: Padding(
                padding: const EdgeInsets.all(25).copyWith(top: 0),
                child: FittedBox(
                  child: Stack(
                    children: [
                      _HandVector(
                        scale: scale,
                        color: backgroundGradient ? null : handColor,
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
            _FadeIn(t, child: child!),
          ],
        ),
      ),
    );
    if (!backgroundGradient) return _TopButtons(t: t, child: zaHando);

    final tHorizon = (t * 2 - 1 / 3).clamp(0.0, 1.0);
    late final handHorizon = HSVColor.lerp(
      HSVColor.fromAHSV(1.0, 0, 1 - tHorizon * 0.75, tHorizon * 0.8),
      handHSV,
      tHorizon,
    )!;

    final BoxDecoration decoration;
    if (kIsWeb) {
      decoration = BoxDecoration(color: handColor);
    } else {
      decoration = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [handColor, handHorizon.toColor()],
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        DecoratedBox(decoration: decoration, child: const SizedBox.expand()),
        zaHando,
      ],
    );
  }

  static const handBounceTime = 0.25;
  static const handTotalTime = 0.5;
  static const minScale = 0.8;
  static const motionRatio = 1 - handBounceTime;

  Widget collapse(BuildContext context, double t, Widget? child) {
    final tHand = min(t / handTotalTime, 1.0);
    final double scale = switch (tHand - handBounceTime) {
      < 0 => 1 - tHand * (1 - minScale) / handBounceTime,
      final tScale => 12 * tScale * tScale + minScale,
    };

    final tMotionLinear = max(1 + (t - 1) / motionRatio, 0.0);
    final tMotion = Curves.ease.transform(tMotionLinear);
    final fontSize = 48 - 10 * tMotion;

    final colors = context.colorScheme;
    final handColor = colors.primary.withOpacity(1 - t * t);

    final heartText = Text(
      'THE HEART',
      style: StyleText(color: Color.lerp(StartColors.dullGreen38, colors.onSurfaceVariant, t)),
    );
    final centerText = Text(
      'CENTER',
      style: StyleText(color: Color.lerp(SunColors.overlayText, colors.onSurfaceVariant, t)),
    );

    final innerHand = DefaultTextStyle(
      style: StyleText(size: fontSize, weight: 720),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(scale: 1 + 0.2 * (1 - tMotion), child: heartText),
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
                  child: Transform.scale(scaleY: 1.1 - 0.1 * tMotion, child: centerText),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final zaHando = Stack(
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
          width: _handWidth,
          height: _handHeight * (1 - tMotion),
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: _HandVector(scale: scale, color: handColor),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 425 * (1 - tMotion), bottom: 20 * tMotion),
          child: innerHand,
        ),
      ],
    );

    return LayoutBuilder(
      builder: (_, constraints) => Stack(
        children: [
          Container(
            margin: const EdgeInsets.all(25),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            width: 450,
            clipBehavior: Clip.hardEdge,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: constraints.maxHeight - 400),
                  child: Padding(
                    padding: EdgeInsets.all(25 * (1 - tMotion)).copyWith(top: 0),
                    child: FittedBox(child: zaHando),
                  ),
                ),
                child!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FadeIn extends StatelessWidget {
  const _FadeIn(this.t, {required this.child});

  final double t;
  final Widget child;
  static const duration = Duration(milliseconds: 1250);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      key: Key('$child opacity'),
      opacity: t.floorToDouble(),
      duration: duration,
      curve: Curves.easeOut,
      child: child,
    );
  }
}

class _TopButtons extends StatelessWidget {
  const _TopButtons({this.t, required this.child});

  final double? t;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 48, height: 48, child: GoBack()),
        const Spacer(),
        if (kDebugMode) ...[
          const SizedBox(width: 48, height: 48, child: ChooseAnyView.button()),
          const SizedBox(width: 16),
        ],
        ThemeModePicker(
          backgroundColor: colors.surface,
          foregroundColor: colors.outline,
        ),
      ],
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox.expand(child: t == null ? row : _FadeIn(t!, child: row)),
        ),
        child,
      ],
    );
  }
}

class _HandVector extends StatelessWidget {
  const _HandVector({required this.scale, required this.color});
  final double scale;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 600,
      height: 800,
      child: Opacity(
        opacity: color == null ? 0 : 1,
        child: Transform.scale(
          scale: scale,
          child: SvgPicture.asset(
            'assets/svg_files/thc_logo.svg',
            placeholderBuilder: (_) => const SizedBox.shrink(),
            colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
