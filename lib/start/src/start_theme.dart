import 'package:flutter/material.dart';
import 'package:thc/utils/theme.dart';

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
