import 'package:flutter/material.dart';
import 'package:thc/start/src/start_theme.dart';
import 'package:thc/utils/bloc.dart';
import 'package:thc/utils/local_storage.dart';
import 'package:thc/utils/style_text.dart';

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
///       style: StyleText(color: colorScheme.onSurface),
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
  static const green67 = Color(0xaa99cc99);
  static const pink = Color(0xffeecce0);
  static const orange = Color(0xffffa020);
  static const teal = Color(0xff00b0b0);
  static const tan = Color(0xfff8f0e0);
  static const gray = Color(0xff4b4f58);
  static const dullBlue = Color(0xff364764);
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
/// I made this extension because of [that one video](https://youtu.be/CylXr3AF3uU?t=449)
/// that told me to.
extension ThatOneVideo on Set<MaterialState> {
  bool get isFocused => contains(MaterialState.focused);
  bool get isSelected => contains(MaterialState.selected);
  bool get isPressed => contains(MaterialState.pressed);
}

const _iconTheme = IconThemeData(size: 32);
const _labelTextStyle = StyleText(size: 12, weight: 600);
final _lightBackground = Color.lerp(ThcColors.paleAzure, Colors.white, 0.33)!;

ThemeData _generateTheme(Brightness brightness) {
  final isLight = brightness == Brightness.light;

  final textColor = isLight ? Colors.black : ThcColors.paleAzure;
  final paleColor = isLight ? Colors.white : ThcColors.paleAzure;
  final slightContrast = isLight ? ThcColors.dullBlue : ThcColors.paleAzure;
  final contrast13 = slightContrast.withOpacity(0.125);
  final contrast25 = slightContrast.withOpacity(0.25);

  MaterialStateProperty<T> selected<T>(T selected, T unselected) =>
      MaterialStateProperty.resolveWith((states) => states.isSelected ? selected : unselected);

  MaterialStateProperty<T> tealWhenSelected<T>(T Function({Color color}) copyWith, bool isLight) {
    return selected(
      copyWith(color: ThcColors.teal),
      copyWith(color: paleColor.withOpacity(0.33)),
    );
  }

  return ThemeData(
    colorScheme: ColorScheme(
      brightness: isLight ? Brightness.light : Brightness.dark,
      primary: isLight ? ThcColors.green : StartColors.zaHando,
      primaryContainer: isLight ? StartColors.dullGreen38 : StartColors.dullGreen50,
      onPrimary: StartColors.dullerGreen,
      inversePrimary: ThcColors.darkGreen,
      secondary: ThcColors.teal,
      onSecondary: Colors.white,
      tertiary: isLight ? ThcColors.darkMagenta : ThcColors.tan,
      onTertiary: isLight ? ThcColors.tan : ThcColors.darkMagenta,
      error: Colors.red.withOpacity(0.75),
      onError: Colors.white,
      errorContainer: Colors.red.withOpacity(0.33),
      onErrorContainer: Colors.red,
      background: isLight ? _lightBackground : ThcColors.darkBlue,
      onBackground: textColor,
      surface: isLight ? ThcColors.tan : ThcColors.dullBlue,
      onSurface: textColor,
      inverseSurface: isLight ? ThcColors.darkBlue : ThcColors.paleAzure,
      onInverseSurface: isLight ? Colors.white : ThcColors.darkBlue,
      surfaceVariant: ThcColors.dullBlue,
      onSurfaceVariant: paleColor,
      outline: slightContrast,
      outlineVariant: contrast25,
    ),
    fontFamily: 'pretendard',
    materialTapTargetSize: MaterialTapTargetSize.padded,
    highlightColor: contrast13,
    hoverColor: contrast13,
    splashColor: contrast13,
    switchTheme: SwitchThemeData(
      thumbColor: selected(Colors.white, slightContrast),
      trackOutlineColor: selected(ThcColors.green, slightContrast),
      trackColor: selected(
        ThcColors.green,
        ThcColors.dullBlue.withOpacity(isLight ? 0.33 : 1),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const BeveledRectangleBorder(),
        textStyle: const StyleText(weight: 600),
      ),
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

  ThemeData editScheme({
    Brightness? brightness,
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? onSecondary,
    Color? secondaryContainer,
    Color? onSecondaryContainer,
    Color? tertiary,
    Color? onTertiary,
    Color? tertiaryContainer,
    Color? onTertiaryContainer,
    Color? error,
    Color? onError,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? background,
    Color? onBackground,
    Color? surface,
    Color? onSurface,
    Color? surfaceVariant,
    Color? onSurfaceVariant,
    Color? outline,
    Color? outlineVariant,
    Color? shadow,
    Color? scrim,
    Color? inverseSurface,
    Color? onInverseSurface,
    Color? inversePrimary,
    Color? surfaceTint,
  }) {
    final theme = Theme.of(this);
    final colors = theme.colorScheme;
    final newScheme = colors.copyWith(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      surfaceVariant: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: onInverseSurface,
      inversePrimary: inversePrimary,
      surfaceTint: surfaceTint,
    );
    return theme.copyWith(colorScheme: newScheme);
  }
}

class AppTheme extends Cubit<ThemeMode> {
  AppTheme() : super(LocalStorage.themeMode());

  static ThemeData of(BuildContext context) {
    final mode = switch (context.watch<AppTheme>().state) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };
    return _generateTheme(mode);
  }

  void newThemeMode(ThemeMode newTheme) {
    LocalStorage.themeMode.save(newTheme.index);
    emit(newTheme);
  }
}
