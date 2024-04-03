import 'package:flutter/material.dart';
import 'package:thc/utils/bloc.dart';
import 'package:thc/utils/local_storage.dart';

/// {@template colorScheme}
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
MaterialStateProperty<T> _selected<T>(T selected, T unselected) {
  return MaterialStateProperty.resolveWith(
    (states) => states.contains(MaterialState.selected) ? selected : unselected,
  );
}

const _iconTheme = IconThemeData(size: 32);
const _labelTextStyle = TextStyle(fontWeight: FontWeight.w600, fontSize: 12);

ThemeData _generateTheme(bool isLight) {
  final textColor = isLight ? Colors.black : ThcColors.paleAzure;
  final slightContrast = isLight ? ThcColors.dullBlue : ThcColors.paleAzure;
  final paleColor = isLight ? Colors.white : ThcColors.paleAzure;

  MaterialStateProperty<T> tealWhenSelected<T>(T Function({Color color}) copyWith, bool isLight) {
    return _selected(
      copyWith(color: ThcColors.teal),
      copyWith(color: paleColor.withOpacity(0.33)),
    );
  }

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
      error: Colors.red.withOpacity(0.75),
      onError: Colors.white,
      errorContainer: Colors.red.withOpacity(0.33),
      onErrorContainer: Colors.red,
      background: isLight ? ThcColors.paleAzure : ThcColors.darkBlue,
      onBackground: textColor,
      surface: isLight ? ThcColors.tan : ThcColors.dullBlue,
      onSurface: textColor,
      inverseSurface: isLight ? ThcColors.darkBlue : ThcColors.paleAzure,
      onInverseSurface: isLight ? Colors.white : ThcColors.darkBlue,
      surfaceVariant: ThcColors.dullBlue,
      onSurfaceVariant: paleColor,
      outline: slightContrast,
      outlineVariant: slightContrast.withOpacity(0.25),
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
      surfaceTintColor: isLight ? null : Colors.black,
    ),
    listTileTheme: ListTileThemeData(iconColor: slightContrast),
    radioTheme: RadioThemeData(
      fillColor: MaterialStatePropertyAll(textColor.withOpacity(0.75)),
    ),
    checkboxTheme: CheckboxThemeData(
      side: BorderSide(color: textColor.withOpacity(0.75), width: 2),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: ThcColors.darkBlue,
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),
      surfaceTintColor: isLight ? Colors.transparent : Colors.black,
      indicatorColor: Colors.transparent,
      iconTheme: tealWhenSelected(_iconTheme.copyWith, isLight),
      labelTextStyle: tealWhenSelected(_labelTextStyle.copyWith, isLight),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
    ),
  );
}

/// {@macro colorScheme}
final lightTheme = _generateTheme(true);

/// {@macro colorScheme}
final darkTheme = _generateTheme(false);

/// `extension` lets you add methods to a class, as if you were
/// doing it inside the class definition.
///
/// {@template ThemeGetter}
/// This extension makes fetching the color scheme a bit cleaner.
///
/// ```dart
/// ColoredBox(color: Theme.of(context).colorScheme.surface) // before
/// ColoredBox(color: context.colorScheme.surface) // after
/// ```
/// {@endtemplate}
extension ThemeGetter on BuildContext {
  ThemeData get theme => Theme.of(this);

  /// {@macro ThemeGetter}
  ColorScheme get colorScheme => theme.colorScheme;

  /// The displayed color will be [light] or [dark] based on
  /// whether we're currently in dark mode.
  Color lightDark(Color light, Color dark) => switch (theme.brightness) {
        Brightness.light => light,
        Brightness.dark => dark,
      };
}

class AppTheme extends Cubit<ThemeMode> {
  AppTheme() : super(StorageKeys.themeMode());

  void newThemeMode(ThemeMode newTheme) {
    StorageKeys.themeMode.save(newTheme.index);
    emit(newTheme);
  }
}
