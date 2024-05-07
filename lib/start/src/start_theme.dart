import 'package:flutter/material.dart';
import 'package:thc/utils/theme.dart';

/// This class is pretty epic: you can fetch the `static` values just like in [ThcColors],
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
  /// Wraps any widget with the "start theme".
  const StartTheme({required this.child, super.key});

  final Widget child;

  /// The theme data that we're using for the login/register screen.
  static ThemeData of(BuildContext context) {
    final current = Theme.of(context);
    final isLight = current.brightness == Brightness.light;

    final container = isLight ? ThcColors.lightContainer : ThcColors.darkContainer;
    return current.copyWith(
      colorScheme: current.colorScheme.copyWith(
        background: ThcColors.startBg,
        surface: container,
        onSurface: isLight ? Colors.black : ThcColors.lightContainer,
        surfaceTint: isLight ? Colors.white : Colors.black,
        onSurfaceVariant: isLight ? ThcColors.startBg12 : ThcColors.lightContainer38,
        outline: isLight ? ThcColors.startBg75 : ThcColors.lightContainer75,
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
          foregroundColor: isLight ? ThcColors.startBg75 : ThcColors.lightContainer75,
        ),
      ),
      iconTheme: IconThemeData(
        color: isLight ? ThcColors.startBg75 : ThcColors.lightContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedTheme(curve: Curves.easeOutSine, data: of(context), child: child);
  }
}
