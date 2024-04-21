import 'package:flutter/material.dart';
import 'package:thc/utils/theme.dart';

abstract final class StartColors {
  /// [bg] with 1/8 (12%) opacity.
  static const bg12 = Color(0x20202428);

  /// [bg] with 3/8 (38%) opacity.
  static const bg38 = Color(0x60202428);

  /// [bg] with 3/4 (75%) opacity.
  static const bg75 = Color(0xc0202428);

  static const bg = Color(0xff202428);

  /// [dullGreen] with 3/8 (38%) opacity.
  static const dullGreen38 = Color(0x6060a060);

  /// [dullGreen] with 1/2 (50%) opacity.
  static const dullGreen50 = Color(0x8060a060);

  static const dullGreen = Color(0xff60a060);

  static const dullerGreen = Color(0xff407040);

  /// [lightContainer] with 3/8 (38%) opacity.
  static const lightContainer38 = Color(0x60c8d8e6);

  /// [lightContainer] with 1/2 (50%) opacity.
  static const lightContainer50 = Color(0x80c8d8e6);

  /// [lightContainer] with 3/4 (75%) opacity.
  static const lightContainer75 = Color(0xc0c8d8e6);

  /// [lightContainer] with 7/8 (87%) opacity.
  static const lightContainer87 = Color(0xe0c8d8e6);

  static const lightContainer = Color(0xffc8d8e6);

  static const darkContainer = Color(0xff101214);

  static const zaHando = Color(0xff80c080);
}

final class SunColors extends RadialGradient {
  const SunColors({super.colors = _colors});

  SunColors.withOpacity(double opacity)
      : this(colors: [for (final color in _colors) color.withOpacity(opacity)]);

  static const _colors = [
    Color(0xffffff00),
    Color(0xfffff000),
    Color(0xffffd500),
  ];

  static const border = Color(0xffffcc00);
  static const glow = Color(0xfffff0e0);
  static const overlayText = Color(0x20ff0000);
}

class StartTheme extends StatelessWidget {
  const StartTheme({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final current = context.theme;
    final isLight = current.brightness == Brightness.light;

    final container = isLight ? StartColors.lightContainer : StartColors.darkContainer;
    return AnimatedTheme(
      curve: Curves.easeOutSine,
      data: current.copyWith(
        colorScheme: current.colorScheme.copyWith(
          background: StartColors.bg,
          surface: container,
          onSurface: isLight ? Colors.black : StartColors.lightContainer,
          surfaceTint: isLight ? Colors.white : Colors.black,
          onSurfaceVariant: isLight ? StartColors.bg12 : StartColors.lightContainer38,
          outline: isLight ? StartColors.bg75 : StartColors.lightContainer75,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: LinearBorder.none,
            backgroundColor: current.colorScheme.primary,
            foregroundColor: current.colorScheme.onPrimary,
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            backgroundColor: container,
            foregroundColor: isLight ? StartColors.bg75 : StartColors.lightContainer75,
          ),
        ),
        iconTheme: IconThemeData(
          color: isLight ? StartColors.bg75 : StartColors.lightContainer,
        ),
      ),
      child: child,
    );
  }
}
