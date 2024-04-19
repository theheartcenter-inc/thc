import 'package:flutter/rendering.dart';

abstract final class StartColors {
  /// [bg] with 1/8 (12%) opacity.
  static const bg12 = Color(0x20202428);
  static const bg = Color(0xff202428);

  /// [dullGreen] with 3/8 (38%) opacity.
  static const dullGreen38 = Color(0x6060a060);
  static const dullGreen = Color(0xff60a060);

  static const lightContainer = Color(0xe0e0f0ff);
}

final class SunColors extends RadialGradient {
  const SunColors() : super(colors: _colors);
  static const _colors = [
    Color(0xffffff00),
    Color(0xfffff000),
    Color(0xffffd500),
  ];

  static RadialGradient withOpacity(double opacity) => RadialGradient(
        colors: [for (final color in _colors) color.withOpacity(opacity)],
      );

  static const border = Color(0xffffcc00);
  static const glow = Color(0xfffff0e0);
  static const overlayText = Color(0x20ff0000);
}
