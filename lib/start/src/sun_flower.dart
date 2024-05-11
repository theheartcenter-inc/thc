import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:thc/utils/num_powers.dart';

typedef SunScheme = ({Color center, Color outer, Color border});

extension MoreTransparent on Color {
  Color moreTransparent(double opacity) => withOpacity(this.opacity * opacity);
}

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
  static const petals = 9;

  static const overlayText = Color(0x50ff0080);
  static const pinkBorder = Color(0xfff03c96);
  static const glow = Color(0xfffff0e0);
  static const innerLines = Color(0xffe00070);

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
    final (:center, :outer, :border) = colors;

    final radius = size.width / 2;
    final borderPath = PolarPath(radius, bulge).border(rotation);
    final fillPaint = Paint()
      ..color = outer
      ..style = PaintingStyle.fill;

    if (bulge == 0) {
      canvas.drawCircle(Offset(radius, radius), radius, fillPaint);
    } else {
      final innerLinePaint = Paint()
        ..color = Sunflower.innerLines.withOpacity(center.opacity * bulge / 3)
        ..strokeWidth = bulge * 4
        ..style = PaintingStyle.stroke;

      final innerPath = PolarPath(radius, bulge).innerLines(rotation);
      canvas.drawPath(borderPath, fillPaint);
      canvas.drawPath(innerPath, innerLinePaint);
    }

    final rect = Offset.zero & size;
    for (final color in [outer, center]) {
      final gradient = RadialGradient(
        colors: [color, color.moreTransparent(2 / 3), color.moreTransparent(0)],
      ).createShader(rect);

      canvas.drawPaint(Paint()..shader = gradient);
    }

    final borderPaint = Paint()
      ..color = border
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(_SunflowerPaint oldDelegate) => true;
}

class PolarPath {
  PolarPath(this.radius, double bulge)
      : path = Path(),
        bulge = Curves.easeOutCirc.transform(bulge);

  Path border(double rotation) {
    moveTo(theta: rotation);
    for (int i = 0; i < Sunflower.petals; i++) {
      arcTo(theta: i * PolarPath.theta + rotation);
    }
    arcTo(theta: rotation);

    return path..close();
  }

  Path innerLines(double rotation) {
    for (int i = 0; i < Sunflower.petals; i++) {
      moveTo(r: 0, theta: 0);
      lineTo(theta: rotation + i * PolarPath.theta);
    }
    return path..close();
  }

  final Path path;
  final double radius;
  final double bulge;
  late final innerRadius = radius * (1 - bulge / 6);
  late final minArcRadius = unitArcLength * innerRadius / 2;
  late final bulgeRadius = innerRadius * ((unitArcLength - 1) * bulge + 1) / (bulge + 1);

  static const theta = math.pi * 2 / Sunflower.petals;
  static final unitArcLength = math.sqrt((1 - math.cos(theta)).squared + math.sin(theta).squared);

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
    path.arcToPoint(Offset(x, y), radius: Radius.circular(bulgeRadius));
  }
}
