import 'package:flutter/material.dart';
import 'package:thc/firebase/firebase_setup.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/home/surveys/edit_survey/survey_editor.dart';
import 'package:thc/home/surveys/take_survey/survey.dart';
import 'package:thc/start/start.dart';
import 'package:thc/utils/bloc.dart';
import 'package:thc/utils/local_storage.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final asyncSetup = <Future>[
    initFirebase(),
    loadFromLocalStorage(),
  ];
  addKeyboardShortcuts();
  await Future.wait(asyncSetup);
  loadUser();

  runApp(const App());
}

final class App extends HookWidget {
  const App() : super(key: null);

  static final _key = Cubit(UniqueKey());
  static void relaunch([_]) {
    navKey = GlobalKey<NavigatorState>();
    _key.value = UniqueKey();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      key: useListenable(_key).value,
      providers: [
        BlocProvider(create: (_) => AppTheme()),
        BlocProvider(create: (_) => MobileEditing()),
        BlocProvider(create: (_) => ValidSurveyQuestions()),
        BlocProvider(create: (_) => ValidSurveyAnswers()),
        BlocProvider(create: (_) => NavBarSelection()),
      ],
      builder: (context, _) => MaterialApp(
        themeAnimationCurve: Curves.easeOutSine,
        navigatorKey: navKey,
        theme: AppTheme.of(context),
        debugShowCheckedModeBanner: false,
        home: LocalStorage.loggedIn() ? const HomeScreen() : const StartScreen(),
      ),
    );
  }
}
