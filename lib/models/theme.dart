import 'package:flutter/material.dart';

/// {@template models.theme.colorScheme}
/// By pulling colors from the [ColorScheme], the color palette can adapt
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
///
/// The THC app colors are based on the color palette from
/// [theheartcenter.one](https://theheartcenter.one/).
/// {@endtemplate}
abstract final class ThcColors {
  static const green = Color(0xff99cc99);
  static const pink = Color(0xffeecce0);
  static const orange = Color(0xffffa020);
  static const teal = Color(0xff00b0b0);
  static const tan = Color(0xfff8f0e0);
  static const dullBlue = Color(0xff364764);
  static const gray = Color(0xff4b4f58);
  static const darkBlue = Color(0xff151c28);
  static const darkGreen = Color(0xff003300);
  static const darkMagenta = Color(0xff663366);
  static const paleAzure = Color(0xffddeeff);
}

/// [MaterialStateProperty] is pretty neat: you can have different styles
/// based on whatever's going on with the widget.
///
/// For example, if a Director clicks on the "stream" button
/// and then keeps their mouse hovering over it, then
/// the button's set of Material states would look like this:
///
/// ```dart
/// states = {MaterialState.hovered, MaterialState.selected};
/// ```
///
/// Since we're using this [_tealWhenSelected] function, the color will be [ThcColors.teal].
MaterialStateProperty<T> _tealWhenSelected<T>(T Function({Color color}) copyWith) =>
    MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.selected)
        ? copyWith(color: ThcColors.teal)
        : copyWith(color: Colors.white));

MaterialStateProperty<Color> _selected(Color selectedColor, Color unselectedColor) =>
    MaterialStateProperty.resolveWith(
        (states) => states.contains(MaterialState.selected) ? selectedColor : unselectedColor);

const _iconTheme = IconThemeData(size: 32);
const _labelTextStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 12);

ThemeData _generateTheme(bool isLight) {
  final textColor = isLight ? Colors.black : ThcColors.paleAzure;
  final slightContrast = isLight ? ThcColors.dullBlue : ThcColors.paleAzure;
  return ThemeData(
    colorScheme: ColorScheme(
      brightness: isLight ? Brightness.light : Brightness.dark,
      primary: ThcColors.green,
      inversePrimary: ThcColors.darkGreen,
      onPrimary: Colors.white,
      secondary: ThcColors.teal,
      onSecondary: Colors.white,
      tertiary: isLight ? ThcColors.darkMagenta : ThcColors.tan,
      onTertiary: isLight ? ThcColors.tan : ThcColors.darkMagenta,
      error: Colors.red,
      onError: Colors.white,
      errorContainer: ThcColors.pink,
      onErrorContainer: Colors.red,
      background: isLight ? ThcColors.paleAzure : ThcColors.darkBlue,
      onBackground: textColor,
      surface: isLight ? ThcColors.tan : ThcColors.dullBlue,
      onSurface: textColor,
    ),
    materialTapTargetSize: MaterialTapTargetSize.padded,
    switchTheme: SwitchThemeData(
      thumbColor: _selected(Colors.white, slightContrast),
      trackOutlineColor: _selected(ThcColors.green, slightContrast),
      trackColor: _selected(
        ThcColors.green,
        ThcColors.dullBlue.withOpacity(isLight ? 0.33 : 1),
      ),
    ),
    filledButtonTheme: const FilledButtonThemeData(
      style: ButtonStyle(shape: MaterialStatePropertyAll(BeveledRectangleBorder())),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: isLight ? Colors.white : ThcColors.paleAzure,
        backgroundColor: ThcColors.dullBlue,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        side: const BorderSide(style: BorderStyle.none),
        backgroundColor: isLight ? Colors.white54 : Colors.black54,
        selectedBackgroundColor: ThcColors.green,
        selectedForegroundColor: isLight ? null : Colors.black,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ThcColors.darkBlue,
      foregroundColor: isLight ? Colors.white : ThcColors.paleAzure,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: isLight ? ThcColors.darkBlue : Colors.transparent,
      indicatorColor: Colors.transparent,
      iconTheme: _tealWhenSelected(_iconTheme.copyWith),
      labelTextStyle: _tealWhenSelected(_labelTextStyle.copyWith),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
    ),
  );
}

/// {@macro models.theme.colorScheme}
final lightTheme = _generateTheme(true);

/// {@macro models.theme.colorScheme}
final darkTheme = _generateTheme(false);

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

  /// The displayed color will be [light] or [dark] based on
  /// whether we're currently in dark mode.
  Color lightDark(Color light, Color dark) => switch (theme.brightness) {
        Brightness.light => light,
        Brightness.dark => dark,
      };
}
