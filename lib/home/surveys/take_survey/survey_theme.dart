import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';

/// The sunrise/sunset gradient does a couple things:
/// 1. adds a nice aesthetic
/// 2. gives a visual indicator of how long the survey is, and how far along you are
abstract final class SurveyColors {
  static const veridian = Color(0xffc03000);
  static const maroon = Color(0xff600030);
  static const orangeWhite = Color(0xffffeee8);
  static const orangeSunrise = Color(0xffffb060);
  static const orangeSunset = Color(0xffc07020);
  static const yellowSunrise = Color(0xffffffa0);
  static const maroonSunset = Color(0xff400020);

  static const vibrantRed = Color(0xffff0000);
  static const sunriseError = Color(0x40ff0000);
  static const sunsetError = Color(0x50600000);
}

/// {@template SurveyStyling}
/// Rather than going to the hassle of changing the app theme,
/// we can just wrap the survey screen in this widget.
///
/// We can also set custom theme data for sliders, buttons,
/// and text fields that show up as survey UI components.
/// {@endtemplate}
class SurveyStyling extends StatelessWidget {
  /// {@macro SurveyStyling}
  const SurveyStyling({required this.child, super.key});

  /// The survey content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = context.theme.brightness;
    final isLight = brightness == Brightness.light;
    final blackAndWhite = isLight ? Colors.white : Colors.black;
    final textColor = isLight ? Colors.black : SurveyColors.orangeWhite;
    final error = isLight ? SurveyColors.vibrantRed : Colors.redAccent;
    final paleColor = isLight ? SurveyColors.yellowSunrise : SurveyColors.orangeWhite;
    final colors = ColorScheme(
      brightness: brightness,
      primary: SurveyColors.veridian,
      primaryContainer: isLight ? SurveyColors.veridian : SurveyColors.orangeWhite,
      onPrimary: blackAndWhite,
      secondary: SurveyColors.maroon,
      onSecondary: blackAndWhite,
      error: error,
      onError: blackAndWhite,
      errorContainer: isLight ? SurveyColors.sunriseError : SurveyColors.sunsetError,
      onErrorContainer: error,
      background: isLight ? SurveyColors.yellowSunrise : SurveyColors.maroonSunset,
      onBackground: textColor,
      surface: isLight ? SurveyColors.orangeSunrise : SurveyColors.orangeSunset,
      onSurface: textColor,
    );
    final size = MediaQuery.of(context).size;
    return Theme(
      data: ThemeData(
        colorScheme: colors,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: textColor)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colors.primaryContainer, width: 1.5),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: SurveyColors.veridian,
          selectionHandleColor: SurveyColors.veridian,
          selectionColor: SurveyColors.veridian.withOpacity(0.5),
        ),
        sliderTheme: SliderThemeData(
          trackHeight: 12,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          activeTickMarkColor: isLight ? SurveyColors.veridian.withOpacity(0.25) : Colors.black12,
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: SegmentedButton.styleFrom(
            side: BorderSide.none,
            backgroundColor: paleColor.withOpacity(0.5),
            foregroundColor: isLight ? SurveyColors.veridian : SurveyColors.maroon,
            selectedBackgroundColor: SurveyColors.veridian,
            selectedForegroundColor: paleColor,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: paleColor,
            foregroundColor: isLight ? Colors.black : SurveyColors.maroonSunset,
            shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(25)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            textStyle: const StyleText(size: 16, weight: 600),
            elevation: isLight ? 1 : null,
          ),
        ),
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: const Alignment(-0.25, -1.0),
                end: const Alignment(0.25, 1.0),
                colors: [colors.surface, colors.background],
              ),
            ),
            constraints: BoxConstraints(minWidth: size.width, minHeight: size.height),
            padding: const EdgeInsets.all(20),
            child: SafeArea(child: child),
          ),
        ),
      ),
    );
  }
}

/// {@template DarkModeSwitch}
/// A switch that matches the "survey theme" aesthetic.
/// {@endtemplate}
class DarkModeSwitch extends StatelessWidget {
  /// {@macro DarkModeSwitch}
  const DarkModeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final bool isLight = colors.brightness == Brightness.light;
    return Align(
      alignment: Alignment.topRight,
      child: Switch(
        thumbIcon: MaterialStatePropertyAll(
          isLight
              ? const Icon(Icons.light_mode, color: SurveyColors.yellowSunrise)
              : const Icon(Icons.dark_mode, color: SurveyColors.maroon),
        ),
        activeTrackColor: SurveyColors.maroon,
        inactiveTrackColor: SurveyColors.yellowSunrise,
        thumbColor: const MaterialStatePropertyAll(Colors.black),
        value: !isLight,
        onChanged: (isLight) {
          context.read<AppTheme>().newThemeMode(isLight ? ThemeMode.dark : ThemeMode.light);
        },
      ),
    );
  }
}
