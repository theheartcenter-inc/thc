import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/home/surveys/edit_survey/survey_editor.dart';
import 'package:thc/home/surveys/edit_survey/survey_field_editor.dart';
import 'package:thc/home/surveys/survey_questions.dart';
import 'package:thc/home/surveys/take_survey/survey.dart';
import 'package:thc/home/surveys/take_survey/survey_theme.dart';
import 'package:thc/login/login.dart';
import 'package:thc/utils/bloc.dart';
import 'package:thc/utils/keyboard_shortcuts.dart';
import 'package:thc/utils/local_storage.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final asyncSetup = [
    initFirebase(),
    loadFromLocalStorage(),
  ];
  HardwareKeyboard.instance.addHandler(shortcuts);
  await Future.wait(asyncSetup);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(create: (_) => AppTheme()),
        BlocProvider(create: (_) => NavBarIndex()),
        BlocProvider(create: (_) => SurveyEditorBloc()),
        BlocProvider(create: (_) => QuestionValidation()),
        BlocProvider(create: (_) => AnswerValidation()),
      ],
      builder: (context, _) => MaterialApp(
        navigatorKey: navKey,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: context.watch<AppTheme>().state,
        debugShowCheckedModeBanner: false,
        home: const ChooseAnyView(),
      ),
    );
  }
}

/// {@template main.ChooseAnyView}
/// Change the value of `home` to anything you want!
///
/// If you're working on the login screen, you can use
/// ```dart
///   home: const LoginScreen(),
/// ```
/// {@endtemplate}
class ChooseAnyView extends StatelessWidget {
  /// {@macro main.ChooseAnyView}
  const ChooseAnyView({super.key});

  @override
  Widget build(BuildContext context) {
    const loginButton = NavigateButton(
      color: Colors.cyan,
      label: 'login',
      page: LoginScreen(),
    );
    final surveyButton = NavigateButton(
      color: switch (context.theme.brightness) {
        Brightness.light => SurveyColors.orangeSunrise,
        Brightness.dark => SurveyColors.maroon,
      },
      label: 'view surveys',
      onPressed: () => navigator.push(const SurveyPicker()),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Image.asset('assets/thc_logo_with_text.png', width: 250),
              const SizedBox(height: 60),
              loginButton,
              for (final type in UserType.values) UserButton(type),
              surveyButton,
            ],
          ),
        ),
      ),
    );
  }
}

class NavigateButton extends StatelessWidget {
  const NavigateButton({
    required this.color,
    required this.label,
    this.page,
    this.onPressed,
    super.key,
  }) : assert((page ?? onPressed) != null);

  final Color color;
  final String label;
  final Widget? page;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: FilledButton(
        onPressed: onPressed ?? () => navigator.pushReplacement(page!),
        style: FilledButton.styleFrom(backgroundColor: color, foregroundColor: Colors.black),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(label, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}

class UserButton extends StatelessWidget {
  const UserButton(this.type, {super.key});
  final UserType type;

  @override
  Widget build(BuildContext context) {
    return NavigateButton(
      color: switch (type) {
        UserType.participant => ThcColors.green,
        UserType.director => ThcColors.tan,
        UserType.admin => ThcColors.dullBlue,
      },
      label: 'view as $type',
      onPressed: () {
        userType = type;
        navigator.pushReplacement(const HomeScreen());
      },
    );
  }
}

class SurveyPicker extends StatelessWidget {
  const SurveyPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            const Spacer(flex: 3),
            const Text('Surveys', style: TextStyle(fontSize: 56, letterSpacing: 0.5)),
            const Spacer(flex: 2),
            for (final option in SurveyPresets.values) _SurveyPickerButton(option),
            const Spacer(),
            DecoratedBox(
              decoration: BoxDecoration(
                color: ThcColors.dullBlue.withAlpha(0x40),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'custom survey',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 25),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => navigator.push(const ViewCustomSurvey()),
                          child: const Text('view'),
                        ),
                        ElevatedButton(
                          onPressed: () => navigator.push(const SurveyEditor()),
                          child: const Text('edit'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 4),
          ],
        ),
      ),
    );
  }
}

class _SurveyPickerButton extends StatelessWidget {
  const _SurveyPickerButton(this.option);
  final SurveyPresets option;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: FilledButton(
        onPressed: () {
          if (option == SurveyPresets.funQuiz) FunQuiz.inProgress = true;
          navigator.push(SurveyScreen(questions: option.questions));
        },
        style: FilledButton.styleFrom(
          backgroundColor: context.lightDark(
            SurveyColors.orangeSunrise,
            SurveyColors.veridian,
          ),
          foregroundColor: context.colorScheme.onSurface,
          shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(25)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: Text(option.label),
      ),
    );
  }
}
