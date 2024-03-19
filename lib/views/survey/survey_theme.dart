import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/settings/settings.dart';
import 'package:thc/views/survey/survey_questions.dart';

abstract final class SurveyColors {
  static const veridian = Color(0xffc03000);
  static const maroon = Color(0xff800040);
  static const orangeWhite = Color(0xffffeee8);
  static const orangeSunrise = Color(0xffffb060);
  static const orangeSunset = Color(0xffc07020);
  static const yellowSunrise = Color(0xffffffa0);
  static const maroonSunset = Color(0xff400020);

  static const vibrantRed = Color(0xffff0000);
  static const sunriseError = Color(0x40ff0000);
  static const sunsetError = Color(0x50600000);
}

class SurveyStyling extends StatelessWidget {
  const SurveyStyling(this.children, {super.key});

  final List<Widget> children;

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
            borderSide: BorderSide(
              color: isLight ? SurveyColors.veridian : SurveyColors.orangeWhite,
              width: 1.5,
            ),
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
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            decoration: FunQuiz.inProgress
                ? BoxDecoration(
                    color: context.lightDark(
                      const Color(0xffccffff),
                      const Color(0xff000808),
                    ),
                  )
                : BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colors.surface, colors.background],
                    ),
                  ),
            constraints: BoxConstraints(minWidth: size.width, minHeight: size.height),
            padding: const EdgeInsets.all(20),
            child: SafeArea(child: Column(children: children)),
          ),
        ),
      ),
    );
  }
}

class DarkModeSwitch extends StatelessWidget {
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
