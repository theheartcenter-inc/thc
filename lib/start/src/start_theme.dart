import 'package:flutter/material.dart';
import 'package:thc/utils/theme.dart';

/// This class copies [Colors] and has numbered names for different opacities:
///
/// - 12% – 1/8
/// - 16% – 5/32
/// - 38% – 3/8
/// - 50% – 1/2
/// - 75% – 3/4
abstract final class StartColors {
  static const bg = Color(0xff202428);
  static const bg12 = Color(0x20202428);
  static const bg75 = Color(0xc0202428);

  static const zaHando = Color(0xff80c080);

  static const dullGreen = Color(0xff60a060);
  static const dullGreen38 = Color(0x6060a060);
  static const dullGreen50 = Color(0x8060a060);

  static const dullerGreen = Color(0xff407040);

  static const lightContainer = Color(0xffc8d8e6);
  static const lightContainer16 = Color(0x28c8d8e6);
  static const lightContainer38 = Color(0x60c8d8e6);
  static const lightContainer75 = Color(0xc0c8d8e6);

  static const darkContainer = Color(0xff101214);
}

/// This class is pretty epic: you can fetch the `static` values just like in [StartColors],
/// and you can also use the constructors to create the gradient for the sun's [Decoration].
final class SunColors extends RadialGradient {
  SunColors.hsv(List<HSVColor> colors) : super(colors: [for (final hsv in colors) hsv.toColor()]);

  SunColors.withOpacity(double opacity)
      : super(colors: [for (final color in _colors) color.withOpacity(opacity)]);

  static const _colors = [
    Color(0xffffff00),
    Color(0xfffff000),
    Color(0xffffd500),
  ];

  /// I tried to figure out how to do [BlendMode.multiply] with [Colors.amber],
  /// but a low-opacity red is both easier and more efficient.
  static const overlayText = Color(0x20ff0000);
  static const border = Color(0xffffcc00);
  static const glow = Color(0xfffff0e0);
}

class StartTheme extends StatelessWidget {
  /// Wraps any widget with the "start theme" [data].
  const StartTheme({required this.child, super.key});

  final Widget child;

  /// The theme data that we're using for the login/register screen.
  static ThemeData data(ThemeData current) {
    final isLight = current.brightness == Brightness.light;

    final container = isLight ? StartColors.lightContainer : StartColors.darkContainer;
    return current.copyWith(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(curve: Curves.easeOutSine, data: data(context.theme), child: child);
  }
}
