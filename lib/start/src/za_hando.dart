/// {@template za_hando}
/// ### 『 ZA HANDO 』
///
/// ![『 ZA HANDO 』](https://static.jojowiki.com/images/thumb/5/59/latest/20201229074308/Za_hando.jpg/400px-Za_hando.jpg)
/// {@endtemplate}
library;

import 'dart:math' as math;

import 'package:flutter_svg/flutter_svg.dart';
import 'package:thc/home/profile/choose_any_view/choose_any_view.dart';
import 'package:thc/start/src/login_fields.dart';
import 'package:thc/start/src/login_progress.dart';
import 'package:thc/start/src/sun_flower.dart';
import 'package:thc/the_good_stuff.dart';
import 'package:thc/utils/widgets/theme_mode_picker.dart';

/// runs when the user presses "start".
void animate() async {
  LoginProgressTracker.update(animation: AnimationProgress.pressStart);
  await Future.delayed(ZaHando.transition);
  LoginProgressTracker.update(animation: AnimationProgress.collapseHand);
  await Future.delayed(ZaHando.collapseDuration);
  LoginField.top.node.requestFocus();
  await Future.delayed(Durations.extralong1);
  LoginProgressTracker.update(animation: AnimationProgress.showBottom);
}

/// {@macro za_hando}
class ZaHando extends StatelessWidget {
  /// {@macro za_hando}
  const ZaHando({super.key});

  static const sunriseDuration = Duration(seconds: 5);
  static const _collapseMs = 1500;
  static const _collapseDuration = Duration(milliseconds: _collapseMs);

  static const transition = Duration(milliseconds: _collapseMs ~/ (1 / bounceHandRatio));
  static const collapseDuration = Duration(milliseconds: _collapseMs ~/ (1 / motionRatio));

  @override
  Widget build(BuildContext context) {
    final pressedStart = LoginProgressTracker.pressedStart(context);

    Widget contents = TweenAnimationBuilder(
      key: ValueKey(pressedStart),
      duration: pressedStart ? _collapseDuration : sunriseDuration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: pressedStart ? collapse : sunrise,
      child: const LoginFields(),
    );

    if (pressedStart) contents = _TopButtons(child: contents);

    return Scaffold(
      backgroundColor: ThcColors.startBg,
      body: SafeArea(child: SizedBox.expand(child: contents)),
    );
  }

  static const _handWidth = 600.0, _handHeight = 800.0;
  static const handSize = Size(_handWidth, _handHeight);
  static const handPadding = 25.0;

  Widget sunrise(BuildContext context, double t, Widget? child) {
    final backgroundGradient = t < 2 / 3;

    final ColorScheme colors = ThcColors.of(context);
    final (tSaturation, tValue) = switch (colors.brightness) {
      Brightness.light => (1 - t * 0.75, t * 0.8),
      Brightness.dark => (1 - t * 2 / 3, t * 0.75),
    };

    final handHSV = HSVColor.fromAHSV(1.0, 180 - t * 60, tSaturation, tValue);
    final handColor = t == 1 ? colors.primary : handHSV.toColor();

    final tSun = Curves.easeOutSine.transform(t);
    final sunCenter = HSVColor.fromAHSV(1, tSun * 30 + 30, 1, (tSun + 1) / 2);
    final sunOuter = sunCenter.withHue(tSun * 30 + 20);

    final tSunrise = Curves.easeOutSine.transform(math.min(t * 1.25, 1));
    final sunOffset = Offset(0, (Sunflower.size + Sunflower.padding * 2.5) * (1 - tSunrise));

    final tContainer = math.max(3 * (t - 1) + 1, 0.0);
    final tSunflower = Curves.easeInOut.transform(math.max(8 / 3 * (t - 1) + 1, 0.0));
    final tHorizon = (3 * t - 1).clamp(0.0, 1.0).squared;

    final tScale = Curves.easeOutExpo.transform(tContainer);
    final scale = 20 * (1 - tScale) + 1.0;

    final heartText = Text(
      'HEART',
      style: TextStyle(color: colors.primaryContainer, weight: 640),
    );
    const centerText = Text(
      'CENTER',
      style: TextStyle(color: Sunflower.overlayText, weight: 720),
    );

    final innerHand = DefaultTextStyle(
      style: const TextStyle(size: 48, weight: 720),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(scale: 1.25, child: _FadeIn(t, child: heartText)),
          Transform.translate(
            offset: sunOffset,
            child: Padding(
              padding: const EdgeInsets.all(Sunflower.padding),
              child: SizedBox.square(
                dimension: Sunflower.size,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Sunflower(
                      bloom: tSunflower,
                      centerColor: Color.lerp(sunCenter.toColor(), Sunflower.center, tSunflower)!,
                      outerColor: Color.lerp(sunOuter.toColor(), Sunflower.outer, tSunflower)!,
                    ),
                    Align(
                      alignment: const Alignment(0, -1 / 32),
                      child: Transform.scale(
                        scaleY: 1.1,
                        child: _FadeIn(t, child: centerText),
                      ),
                    ),
                  ],
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
              key: const Key('za hando'),
              constraints: BoxConstraints(maxHeight: constraints.maxHeight - 275),
              child: Padding(
                padding: const EdgeInsets.all(handPadding).copyWith(top: 0),
                child: FittedBox(
                  child: Stack(
                    children: [
                      _HandVector(
                        scale: scale,
                        color: backgroundGradient ? null : handColor,
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 420),
                            child: innerHand,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (tHorizon < 1) Horizon(t: tHorizon, brightness: colors.brightness),
            _FadeIn(key: const Key('bottom stuff'), t, child: child!),
          ],
        ),
      ),
    );
    if (!backgroundGradient) return _TopButtons(t: t, child: zaHando);

    final tBottomColor = (t * 2 - 1 / 3).clamp(0.0, 1.0);
    late final HSVColor bottomColor = HSVColor.lerp(
      HSVColor.fromAHSV(1.0, 0, 1 - tBottomColor * 0.75, tBottomColor * 0.8),
      handHSV,
      tBottomColor,
    )!;

    final BoxDecoration decoration = kIsWeb
        ? BoxDecoration(color: handColor)
        : BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [handColor, bottomColor.toColor()],
              stops: const [0, 0.75],
            ),
          );

    return Stack(
      alignment: Alignment.center,
      children: [
        DecoratedBox(decoration: decoration, child: const SizedBox.expand()),
        zaHando,
      ],
    );
  }

  static const bounceHandRatio = 0.25;
  static const totalHandRatio = 0.5;
  static const minScale = 0.8;
  static const motionRatio = 1 - bounceHandRatio;

  Widget collapse(BuildContext context, double t, Widget? child) {
    final tHand = math.min(t / totalHandRatio, 1.0);
    final double scale = switch (tHand - bounceHandRatio) {
      < 0 => 1 - tHand * (1 - minScale) / bounceHandRatio,
      final tScale => 12 * tScale.squared + minScale,
    };

    final t2 = t.squared;
    final tMotionLinear = math.max(1 + (t - 1) / motionRatio, 0.0);
    final tMotion = Curves.ease.transform(tMotionLinear);
    final fontSize = 48 - 10 * tMotion;
    final flowerHeight = Sunflower.size * (1 - tMotion);
    final flowerOpacity = 1 - tHand;

    final ColorScheme colors = ThcColors.of(context);
    final handColor = colors.primary.withOpacity(1 - t2);

    final targetColor = colors.onSurfaceVariant;
    final heartText = Text(
      'HEART',
      style: TextStyle(
        color: Color.lerp(ThcColors.dullGreen38, targetColor, t),
        weight: 640 + 80 * t2,
      ),
    );
    final centerText = Text(
      'CENTER',
      style: TextStyle(
        color: Color.lerp(Sunflower.overlayText, targetColor, t),
        weight: 720,
      ),
    );

    final innerHand = DefaultTextStyle(
      style: TextStyle(size: fontSize, weight: 720),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(scale: 1 + 0.25 * (1 - tMotion), child: heartText),
          Padding(
            padding: EdgeInsets.all(Sunflower.padding * (1 - tMotion)),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                if (t < 1)
                  Transform.scale(
                    scale: scale,
                    child: SizedBox(
                      width: Sunflower.size,
                      height: flowerHeight,
                      child: Sunflower(
                        centerColor: Sunflower.center.withOpacity(flowerOpacity),
                        outerColor: Sunflower.outer.withOpacity(flowerOpacity),
                      ),
                    ),
                  ),
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: Sunflower.size, minHeight: flowerHeight),
                  child: Align(
                    alignment: const Alignment(0, -1 / 32),
                    child: Transform.scale(scaleY: 1.1 - 0.1 * tMotion, child: centerText),
                  ),
                ),
              ],
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
          padding: EdgeInsets.only(top: 420 * (1 - tMotion), bottom: 20 * tMotion),
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
                  constraints: BoxConstraints(maxHeight: constraints.maxHeight - 275),
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
  const _FadeIn(this.t, {super.key, required this.child});

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
  /// The "top buttons" include:
  /// - [ThemeModePicker]
  /// - [ChooseAnyView] button (if in debug mode)
  /// - [BackButton] (if applicable to the current [LoginLabels])
  const _TopButtons({this.t, required this.child});

  final double? t;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = ThcColors.of(context);

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
