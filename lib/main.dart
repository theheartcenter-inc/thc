import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:thc/firebase_options.dart';
import 'package:thc/models/bloc.dart';
import 'package:thc/models/local_storage.dart';
import 'package:thc/models/navigator.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/models/user.dart';
import 'package:thc/views/home/home_screen.dart';
import 'package:thc/views/login_register/register.dart';
import 'package:thc/views/profile/settings.dart';
import 'package:thc/views/surveys/edit_survey/survey_editor.dart';
import 'package:thc/views/surveys/survey_questions.dart';
import 'package:thc/views/surveys/take_survey/survey_screen.dart';
import 'package:thc/views/surveys/take_survey/survey_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = loadFromLocalStorage();
  final firebase = Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  HardwareKeyboard.instance.addHandler((event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      navigator.pop();
      return true;
    }
    return false;
  });
  await storage;
  await firebase;
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
    const registerButton = NavigateButton(
      color: Colors.cyan,
      label: 'login/register',
      page: RegisterScreen(),
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
              registerButton,
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
