import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:thc/start/src/za_hando.dart';
import 'package:thc/utils/bloc.dart';

class Sunflower extends HookWidget {
  const Sunflower({
    required this.centerColor,
    required this.outerColor,
    this.bloom = 1,
  }) : super(key: const GlobalObjectKey('Sunflower'));

  final Color centerColor;
  final Color outerColor;

  /// `0.0` → just a circle
  ///
  /// `1.0` → petals!
  final double bloom;

  static const size = 260.0;
  static const padding = 20.0;
  static const petalCount = 9;

  static const glow = Color(0xfffff0e0);
  static const center = Color(0xffffc0f0);
  static const outer = Color(0xffff55d6);
  static const border = Color(0xffee2288);
  static const overlayText = Color(0x50ff0080);

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1666),
      upperBound: PolarPath.theta,
    );
    useOnce(controller.repeat);
    final rotation = useAnimation(controller);

    return CustomPaint(
      size: const Size.square(Sunflower.size),
      willChange: true,
      painter: _SunflowerPaint(
        centerColor: centerColor,
        outerColor: outerColor,
        bloom: bloom,
        rotation: rotation,
      ),
    );
  }
}

class _SunflowerPaint extends CustomPainter {
  _SunflowerPaint({
    required this.centerColor,
    required this.outerColor,
    required this.bloom,
    required this.rotation,
  });

  final Color centerColor;
  final Color outerColor;
  final double bloom;
  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final blooming = bloom > 0;
    final borderOpacity = centerColor.opacity;

    final radius = size.width / 2;
    final centerOffset = Offset(radius, radius);
    final polarPath = PolarPath(radius, bloom, rotation);
    final borderPath = polarPath.borderPath();
    final bloom2 = bloom.squared;

    late final glowPaint = Paint()
      ..color = Sunflower.glow.withOpacity((1 + bloom) / 2)
      ..maskFilter = MaskFilter.blur(BlurStyle.solid, 25 * (1 - bloom).squared);

    final fillPaint = Paint()
      ..color = outerColor
      ..style = PaintingStyle.fill;

    if (blooming) {
      final petalLinePaint = Paint()
        ..color = Sunflower.border.withOpacity(borderOpacity.cubed * bloom / 2)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;

      if (bloom < 1) canvas.drawPath(borderPath, glowPaint);
      canvas.drawPath(borderPath, fillPaint);
      canvas.drawPath(polarPath.innerLines(), petalLinePaint);
    } else {
      canvas.drawCircle(centerOffset, radius, glowPaint);
      canvas.drawCircle(centerOffset, radius, fillPaint);
    }

    final rect = Rect.fromCircle(
      center: centerOffset,
      radius: lerpDouble(polarPath.innerRadius, radius, bloom2)!,
    );
    for (final (color, opacity) in [if (blooming) (outerColor, 0.875), (centerColor, 2 / 3)]) {
      final gradient = RadialGradient(colors: [
        color,
        color.withOpacity(color.opacity * opacity),
        color.withOpacity(0),
      ]).createShader(rect);

      canvas.drawPaint(Paint()..shader = gradient);
    }

    final borderPaint = Paint()
      ..color = Sunflower.border.withOpacity(borderOpacity * bloom2)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    if (blooming) canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(_SunflowerPaint oldDelegate) => true;
}

/// {@template polar_coordinates}
/// Normally, using the cartesian coordinate system `(x, y)` is best,
/// but when you're making circles, polar coordinates `(r, θ)` is a lot cleaner.
/// {@endtemplate}
class PolarPath {
  /// {@macro polar_coordinates}
  PolarPath(this.radius, double bloom, this.rotation)
      : bloom = Curves.easeOutCirc.transform(bloom);

  Path borderPath() {
    path = Path();
    moveTo(theta: rotation);
    for (int i = 0; i < Sunflower.petalCount; i++) {
      arcTo(theta: i * PolarPath.theta + rotation);
      arcTo(r: 1 + bloom.cubed * 1 / 3, theta: (i + 0.5) * PolarPath.theta + rotation);
    }
    arcTo(theta: rotation);

    return path..close();
  }

  Path innerLines() {
    path = Path();
    for (int i = 0; i < Sunflower.petalCount; i++) {
      moveTo(r: 0, theta: 0);
      lineTo(theta: rotation + i * PolarPath.theta);
    }
    return path..close();
  }

  late Path path;
  final double radius;
  final double bloom;
  final double rotation;

  late final innerRadius = radius * (1 - bloom / 5.5);
  late final bloomRadius = Radius.circular(innerRadius / (1 + bloom / 2));

  /// The angle, in radians, that each flower petal spans.
  static const theta = math.pi * 2 / Sunflower.petalCount;

  /// Converts polar coordinates to cartesian.
  (double x, double y) coordsFrom(double r, double theta) => (
        radius + r * innerRadius * math.cos(theta),
        radius + r * innerRadius * math.sin(theta),
      );

  void moveTo({double r = 1.0, required double theta}) {
    final (x, y) = coordsFrom(r, theta);
    path.moveTo(x, y);
  }

  void lineTo({double r = 1.0, required double theta}) {
    final (x, y) = coordsFrom(r, theta);
    path.lineTo(x, y);
  }

  void arcTo({double r = 1.0, required double theta}) {
    final (x, y) = coordsFrom(r, theta);
    path.arcToPoint(Offset(x, y), radius: bloomRadius);
  }
}

class Horizon extends StatelessWidget {
  const Horizon({super.key, required this.t, required this.brightness});

  final double t;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final (hSaturation, hValue) = switch (brightness) {
      Brightness.light => (0.5, 8 / 15),
      Brightness.dark => (5 / 9, 0.5),
    };
    final color = HSVColor.fromAHSV(1.0, 120 + 20 * t, hSaturation, t * hValue).toColor();

    return CustomPaint(painter: _HorizonPainter(color), willChange: t != 0);
  }
}

/// The dark part of the screen below the sun.
class _HorizonPainter extends CustomPainter {
  /// The dark part of the screen below the sun.
  const _HorizonPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const big = 1.0E+9;

    canvas.drawRect(
      const Rect.fromLTRB(-big, -ZaHando.handPadding, big, big),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_HorizonPainter oldDelegate) => color != oldDelegate.color;
}
