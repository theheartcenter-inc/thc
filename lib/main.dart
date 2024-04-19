import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/home/profile/account/account_field.dart';
import 'package:thc/home/surveys/edit_survey/survey_editor.dart';
import 'package:thc/home/surveys/take_survey/survey.dart';
import 'package:thc/start/start.dart';
import 'package:thc/utils/bloc.dart';
import 'package:thc/utils/keyboard_shortcuts.dart';
import 'package:thc/utils/local_storage.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  addKeyboardShortcuts();

  final asyncSetup = [
    initFirebase(),
    loadFromLocalStorage(),
  ];
  await Future.wait(asyncSetup);

  runApp(const App());
}

class App extends StatelessWidget {
  const App() : super(key: null);

  static final _key = _AppKey();
  static void relaunch() {
    navKey = GlobalKey<NavigatorState>();
    _key.emit(UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _key,
      builder: (context, _) => MultiProvider(
        key: context.watch<_AppKey>().state,
        providers: [
          BlocProvider(create: (_) => AppTheme()),
          BlocProvider(create: (_) => NavBarIndex()),
          BlocProvider(create: (_) => MobileEditing()),
          BlocProvider(create: (_) => ValidSurveyQuestions()),
          BlocProvider(create: (_) => ValidSurveyAnswers()),
          BlocProvider(create: (_) => AccountFields()),
        ],
        builder: (context, _) => MaterialApp(
          navigatorKey: navKey,
          theme: AppTheme.of(context),
          debugShowCheckedModeBanner: false,
          home: StorageKeys.loggedIn() ? const HomeScreen() : const StartScreen(),
        ),
      ),
    );
  }
}

class _AppKey extends Cubit<Key> {
  _AppKey() : super(UniqueKey());
}
