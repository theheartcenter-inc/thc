import 'package:thc/the_good_stuff.dart';

/// This class copies [Colors] and has numbered names for different opacities:
///
/// - 12% – 1/8
/// - 16% – 5/32
/// - 38% – 3/8
/// - 50% – 1/2
/// - 75% – 3/4
///
/// {@template colorScheme}
/// By pulling colors from the [ColorScheme], the color palette can adapt
/// based on whether the app is in light or dark mode.
///
/// ```dart
/// Widget build(BuildContext context) {
///   final ColorScheme colors = ThcColors.of(context);
///   return ColoredBox(
///     color: colors.surface,
///     child: Text(
///       'Hello World',
///       style: StyleText(color: colors.onSurface),
///     ),
///   );
/// }
/// ```
/// {@endtemplate}
abstract final class ThcColors {
  // from theheartcenter.one color palette
  static const green = Color(0xff99cc99);
  static const green67 = Color(0xaa99cc99);
  static const pink = Color(0xffeecce0);
  static const orange = Color(0xffffa020);
  static const teal = Color(0xff00b0b0);
  static const tan = Color(0xfff8f0e0);
  static const gray = Color(0xff4b4f58);
  static const darkGreen = Color(0xff003300);
  static const darkMagenta = Color(0xff663366);
  static const paleAzure = Color(0xffddeeff);
  static const dullBlue = Color(0xff364764);
  static const darkBlue = Color(0xff151c28);

  // the rest was added for this app
  static const darkerBlue = Color(0xff080d18);
  static const darkestBlue = Color(0xff060a12);
  static const paleAzure88 = Color(0xe0ddeeff);
  static const veryPaleAzure = Color(0xffe8f4ff);

  static const startBg = Color(0xff202428);
  static const startBg12 = Color(0x20202428);
  static const startBg75 = Color(0xc0202428);

  static const zaHando = Color(0xff80c080);

  static const dullGreen = Color(0xff60a060);
  static const dullGreen38 = Color(0x6060a060);
  static const dullGreen50 = Color(0x8060a060);

  static const dullerGreen = Color(0xff387038);

  static const lightContainer = Color(0xffc8d8e6);
  static const lightContainer16 = Color(0x28c8d8e6);
  static const lightContainer38 = Color(0x60c8d8e6);
  static const lightContainer75 = Color(0xc0c8d8e6);

  static const darkContainer = Color(0xff101214);

  /// {@macro colorScheme}
  static ColorScheme of(BuildContext context) => Theme.of(context).colorScheme;
}

/// [WidgetStateProperty] is pretty neat: you can have different styles
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
extension ThatOneVideo on Set<WidgetState> {
  bool get isFocused => contains(WidgetState.focused);
  bool get isSelected => contains(WidgetState.selected);
  bool get isPressed => contains(WidgetState.pressed);
  bool get isError => contains(WidgetState.error);
}

ThemeData _generateTheme(Brightness brightness) {
  final isLight = brightness == Brightness.light;

  final barColor = isLight ? ThcColors.darkBlue : ThcColors.darkerBlue;
  final slightContrast = isLight ? ThcColors.dullBlue : ThcColors.paleAzure88;

  final colors = ColorScheme.fromSeed(
    seedColor: ThcColors.darkBlue,
    brightness: isLight ? Brightness.light : Brightness.dark,
    primary: isLight ? ThcColors.green : ThcColors.zaHando,
    onPrimary: Colors.black87,
    inversePrimary: ThcColors.darkGreen,
    primaryContainer: isLight ? ThcColors.dullGreen38 : ThcColors.dullGreen50,
    secondary: ThcColors.dullBlue,
    onSecondary: isLight ? Colors.white : ThcColors.paleAzure,
    tertiary: ThcColors.teal,
    onTertiary: isLight ? ThcColors.tan : ThcColors.darkMagenta,
    surface: isLight ? ThcColors.veryPaleAzure : ThcColors.darkestBlue,
    onSurface: isLight ? Colors.black : ThcColors.paleAzure88,
    surfaceContainerLowest: isLight ? Colors.white : Colors.black,
    inverseSurface: isLight ? ThcColors.darkBlue : ThcColors.paleAzure,
    onInverseSurface: isLight ? Colors.white : ThcColors.darkestBlue,
    outline: slightContrast,
    outlineVariant: slightContrast.withOpacity(0.25),
  );

  final inkColor = slightContrast.withOpacity(0.125);
  final onSurface75 = colors.onSurface.withOpacity(0.75);
  final onSurface50 = colors.onSurface.withOpacity(0.5);

  const iconTheme = IconThemeData(size: 32);
  const labelTextStyle = TextStyle(size: 12, weight: 600);
  final inputLabelStyle = WidgetStateTextStyle.resolveWith((states) {
    if (states.isError) return TextStyle(color: colors.error);
    return TextStyle(color: states.isFocused ? colors.primary : colors.onSurface);
  });

  WidgetStateProperty<T> selected<T>(T selected, T unselected) =>
      WidgetStateProperty.resolveWith((states) => states.isSelected ? selected : unselected);

  WidgetStateProperty<T> tealWhenSelected<T>(T Function({Color color}) copyWith, bool isLight) {
    return selected(
      copyWith(color: ThcColors.teal),
      copyWith(color: colors.onSecondary.withOpacity(1 / 3)),
    );
  }

  return ThemeData(
    colorScheme: colors,
    fontFamily: 'pretendard',
    materialTapTargetSize: MaterialTapTargetSize.padded,
    canvasColor: colors.surface,
    scaffoldBackgroundColor: colors.surface,
    highlightColor: inkColor,
    hoverColor: inkColor,
    splashColor: inkColor,
    inputDecorationTheme: InputDecorationTheme(
      border: MaterialStateOutlineInputBorder.resolveWith((states) {
        final Color? error = states.isError ? colors.error : null;
        return OutlineInputBorder(
          borderSide: states.isFocused
              ? BorderSide(color: error ?? colors.primary, width: 2)
              : BorderSide(color: error ?? onSurface50),
        );
      }),
      labelStyle: inputLabelStyle,
      floatingLabelStyle: inputLabelStyle,
    ),
    iconTheme: IconThemeData(color: colors.onSurface),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: Colors.black87),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: selected(Colors.white, colors.outline),
      trackOutlineColor: selected(ThcColors.green, colors.outline),
      trackColor: selected(
        ThcColors.green,
        ThcColors.dullBlue.withOpacity(isLight ? 0.33 : 1),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const BeveledRectangleBorder(),
        textStyle: const TextStyle(weight: 600),
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
      backgroundColor: barColor,
      foregroundColor: colors.onSecondary,
      surfaceTintColor: Colors.transparent,
    ),
    listTileTheme: ListTileThemeData(iconColor: colors.outline),
    radioTheme: RadioThemeData(
      fillColor: WidgetStatePropertyAll(onSurface75),
    ),
    checkboxTheme: CheckboxThemeData(
      side: BorderSide(color: onSurface75, width: 2),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: barColor,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      surfaceTintColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      iconTheme: tealWhenSelected(iconTheme.copyWith, isLight),
      labelTextStyle: tealWhenSelected(labelTextStyle.copyWith, isLight),
      labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
    ),
  );
}

/// `extension` lets you add methods to a class, as if you were
/// doing it inside the class definition.
extension LightDark on BuildContext {
  /// The displayed color will be [light] or [dark] based on
  /// whether we're currently in dark mode.
  Color lightDark(Color light, Color dark) => switch (Theme.of(this).brightness) {
        Brightness.light => light,
        Brightness.dark => dark,
      };
}

class AppTheme extends Cubit<ThemeMode> {
  AppTheme() : super(LocalStorage.themeMode());

  static ThemeData of(BuildContext context) {
    final mode = switch (context.watch<AppTheme>().value) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context),
    };
    return _generateTheme(mode);
  }

  void newThemeMode(ThemeMode newTheme) {
    LocalStorage.themeMode.save(newTheme.index);
    value = newTheme;
  }
}
