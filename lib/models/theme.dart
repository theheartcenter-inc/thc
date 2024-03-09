import 'package:flutter/material.dart';

/// {@template models.theme.colorScheme}
/// The THC app colors are based on the color palette from
/// [theheartcenter.one](https://theheartcenter.one/).
///
/// Names starting with an `_underscore` are private: they can't be accessed
/// from another file.
///
/// Instead, by pulling colors from the `colorScheme`, the color palette can adapt
/// based on whether the app is in light or dark mode.
///
/// ```dart
/// Widget build(BuildContext context) {
///   final colorScheme = Theme.of(context).colorScheme;
///   return ColoredBox(
///     color: colorScheme.surface,
///     child: Text(
///       'Hello World',
///       style: TextStyle(color: colorScheme.onSurface),
///     ),
///   );
/// }
/// ```
/// {@endtemplate}
abstract final class _ThcColors {
  static const green = Color(0xff99cc99);
  static const pink = Color(0xffeecce0);
  static const orange = Color(0xffffa020);
  static const teal = Color(0xff00b0b0);
  static const tan = Color(0xfff8f0e0);
  static const dullBlue = Color(0xff364764);
  static const darkBlue = Color(0xff151c28);
  static const darkGreen = Color(0xff003300);
  static const darkMagenta = Color(0xff663366);
  static const paleAzure = Color(0xffddeeff);
  static const red = Colors.red;
  static const white = Colors.white;
  static const black = Colors.black;
}

/// {@macro models.theme.colorScheme}
final lightTheme = ThemeData(
  materialTapTargetSize: MaterialTapTargetSize.padded,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: _ThcColors.green,
    inversePrimary: _ThcColors.darkGreen,
    onPrimary: _ThcColors.white,
    secondary: _ThcColors.teal,
    onSecondary: _ThcColors.white,
    tertiary: _ThcColors.darkMagenta,
    onTertiary: _ThcColors.tan,
    error: _ThcColors.red,
    onError: _ThcColors.white,
    errorContainer: _ThcColors.pink,
    onErrorContainer: _ThcColors.red,
    background: _ThcColors.paleAzure,
    onBackground: _ThcColors.black,
    surface: _ThcColors.dullBlue,
    onSurface: _ThcColors.white,
    inverseSurface: _ThcColors.darkBlue,
    onInverseSurface: _ThcColors.orange,
  ),
);

/// {@macro models.theme.colorScheme}
final darkTheme = ThemeData(
  materialTapTargetSize: MaterialTapTargetSize.padded,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: _ThcColors.green,
    onPrimary: _ThcColors.white,
    primaryContainer: _ThcColors.darkGreen,
    onPrimaryContainer: _ThcColors.white,
    secondary: _ThcColors.teal,
    onSecondary: _ThcColors.white,
    tertiary: _ThcColors.tan,
    onTertiary: _ThcColors.darkMagenta,
    error: _ThcColors.red,
    onError: _ThcColors.white,
    background: _ThcColors.darkBlue,
    onBackground: _ThcColors.paleAzure,
    surface: _ThcColors.dullBlue,
    onSurface: _ThcColors.paleAzure,
  ),
);

/// `extension` lets you add methods to a class, as if you were
/// doing it inside the class definition.
///
/// {@template models.theme.ThemeGetter}
/// This extension makes fetching the color scheme a bit cleaner.
///
/// ```dart
/// ColoredBox(color: Theme.of(context).colorScheme.surface) // before
/// ColoredBox(color: context.colorScheme.surface) // after
/// ```
/// {@endtemplate}
extension ThemeGetter on BuildContext {
  ThemeData get theme => Theme.of(this);

  /// {@macro models.theme.ThemeGetter}
  ColorScheme get colorScheme => theme.colorScheme;
}
