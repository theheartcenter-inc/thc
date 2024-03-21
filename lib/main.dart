import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/models/bloc.dart';
import 'package:thc/models/local_storage.dart';
import 'package:thc/models/navigator.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/models/user.dart';
import 'package:thc/views/home/director_home.dart';
import 'package:thc/views/home/home_screen.dart';
import 'package:thc/views/login_register/register.dart';
import 'package:thc/views/settings/settings.dart';
import 'package:thc/views/survey/survey_questions.dart';
import 'package:thc/views/survey/survey_screen.dart';
import 'package:thc/views/survey/survey_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadFromLocalStorage();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(create: (_) => AppTheme()),
        BlocProvider(create: (_) => DirectorNavigation()),
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
      page: const SurveyPicker(),
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
    required this.page,
    this.onPressed,
    super.key,
  });
  final Color color;
  final String label;
  final Widget page;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: FilledButton(
        onPressed: () {
          onPressed?.call();
          navigator.pushReplacement(page);
        },
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
      onPressed: () => userType = type,
      page: const HomeScreen(),
    );
  }
}

class SurveyPicker extends StatelessWidget {
  const SurveyPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [Padding(padding: EdgeInsets.all(20), child: DarkModeSwitch())],
      ),
      body: Center(
        child: Column(
          children: [
            const Spacer(flex: 3),
            const Text('Surveys', style: TextStyle(fontSize: 56, letterSpacing: 0.5)),
            const Spacer(flex: 2),
            for (final option in SurveyPresets.values) _SurveyPickerButton(option),
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
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => SurveyValidation(),
              child: SurveyScreen(questions: option.questions),
            ),
          ));
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
