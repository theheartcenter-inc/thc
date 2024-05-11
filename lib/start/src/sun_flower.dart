import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:thc/start/src/za_hando.dart';
import 'package:thc/utils/num_powers.dart';

typedef SunScheme = ({Color center, Color outer});

class Sunflower extends StatefulWidget {
  Sunflower({required this.colors, this.bulge = 1}) : super(key: _key);

  final SunScheme colors;

  /// `0.0` → just a circle
  ///
  /// `1.0` → a bunch of semicircle bumps
  final double bulge;

  static final _key = GlobalKey<_SunflowerState>();
  static const size = 260.0;
  static const padding = 20.0;
  static const petalCount = 9;

  static const glow = Color(0xfffff0e0);
  static const center = Color(0xffffc0f0);
  static const outer = Color(0xffff55d6);
  static const border = Color(0xffee2288);
  static const overlayText = Color(0x50ff0080);

  @override
  State<Sunflower> createState() => _SunflowerState();
}

class _SunflowerState extends State<Sunflower> with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1666),
  )..repeat();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => CustomPaint(
        size: const Size.square(Sunflower.size),
        painter: _SunflowerPaint(
          colors: widget.colors,
          bulge: widget.bulge,
          controller: controller,
        ),
        willChange: true,
      ),
    );
  }
}

class _SunflowerPaint extends CustomPainter {
  _SunflowerPaint({
    required this.colors,
    required this.bulge,
    required AnimationController controller,
  }) : rotation = controller.value * PolarPath.theta;

  final SunScheme colors;
  final double bulge;
  final double rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final (:center, :outer) = colors;
    final blooming = bulge > 0;
    final borderOpacity = center.opacity;

    final radius = size.width / 2;
    final centerOffset = Offset(radius, radius);
    final polarPath = PolarPath(radius, bulge, rotation);
    final borderPath = polarPath.borderPath();

    late final glowPaint = Paint()
      ..color = Sunflower.glow.withOpacity((1 + bulge) / 2)
      ..maskFilter = MaskFilter.blur(BlurStyle.solid, 25 * (1 - bulge).squared);

    final fillPaint = Paint()
      ..color = outer
      ..style = PaintingStyle.fill;

    if (blooming) {
      final petalLinePaint = Paint()
        ..color = Sunflower.border.withOpacity(borderOpacity.cubed * bulge / 2)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;

      if (bulge < 1) canvas.drawPath(borderPath, glowPaint);
      canvas.drawPath(borderPath, fillPaint);
      canvas.drawPath(polarPath.innerLines(), petalLinePaint);
    } else {
      canvas.drawCircle(centerOffset, radius, glowPaint);
      canvas.drawCircle(centerOffset, radius, fillPaint);
    }

    final rect = Rect.fromCircle(
      center: centerOffset,
      radius: lerpDouble(polarPath.innerRadius, radius, bulge.squared)!,
    );
    for (final (color, opacity) in [if (blooming) (outer, 7 / 8), (center, 2 / 3)]) {
      final gradient = RadialGradient(
        colors: [
          color,
          color.withOpacity(color.opacity * opacity),
          color.withOpacity(0),
        ],
      ).createShader(rect);

      canvas.drawPaint(Paint()..shader = gradient);
    }

    final borderPaint = Paint()
      ..color = Sunflower.border.withOpacity(borderOpacity * bulge.squared)
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
  PolarPath(this.radius, double bulge, this.rotation)
      : bulge = Curves.easeOutCirc.transform(bulge);

  Path borderPath() {
    path = Path();
    moveTo(theta: rotation);
    for (int i = 0; i < Sunflower.petalCount; i++) {
      arcTo(theta: i * PolarPath.theta + rotation);
      arcTo(r: 1 + bulge.cubed * 1 / 3, theta: (i + 0.5) * PolarPath.theta + rotation);
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
  final double bulge;
  final double rotation;

  late final innerRadius = radius * (1 - bulge / 5.5);
  late final bulgeRadius = Radius.circular(innerRadius / (1 + bulge / 2));

  /// The angle, in radians, of each flower petal
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
    path.arcToPoint(Offset(x, y), radius: bulgeRadius);
  }
}

/// The dark part of the screen below the sun.
class Horizon extends CustomPainter {
  /// The dark part of the screen below the sun.
  const Horizon({required this.t, required this.brightness});
  final double t;
  final Brightness brightness;

  Widget get widget => CustomPaint(painter: this, willChange: t < 1);

  @override
  void paint(Canvas canvas, Size size) {
    if (t == 1) return;

    final (hSaturation, hValue) = switch (brightness) {
      Brightness.light => (0.5, 8 / 15),
      Brightness.dark => (5 / 9, 0.5),
    };
    final color = HSVColor.fromAHSV(1.0, 120 + 20 * t, hSaturation, t * hValue);

    const big = 1.0E+9;
    canvas.drawRect(
      const Rect.fromLTRB(-big, -ZaHando.handPadding, big, big),
      Paint()..color = color.toColor(),
    );
  }

  @override
  bool shouldRepaint(Horizon oldDelegate) => t != oldDelegate.t;
}
