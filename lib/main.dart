import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/firebase/firebase_setup.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/home/profile/account/account_field.dart';
import 'package:thc/home/surveys/edit_survey/survey_editor.dart';
import 'package:thc/home/surveys/take_survey/survey.dart';
import 'package:thc/home/users/src/all_users.dart';
import 'package:thc/start/start.dart';
import 'package:thc/utils/keyboard_shortcuts.dart';
import 'package:thc/utils/local_storage.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final asyncSetup = [
    initFirebase(),
    loadFromLocalStorage(),
  ];
  addKeyboardShortcuts();
  await Future.wait(asyncSetup);
  loadUser();

  runApp(const App());
}

class App extends StatelessWidget {
  const App() : super(key: null);

  static final _key = _AppKey();
  static void relaunch([_]) {
    navKey = GlobalKey<NavigatorState>();
    _key.value = UniqueKey();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _key,
      builder: (context, _) => MultiProvider(
        key: context.watch<_AppKey>().value,
        providers: [
          ChangeNotifierProvider(create: (_) => AppTheme()),
          ChangeNotifierProvider(create: (_) => NavBarSelection()),
          ChangeNotifierProvider(create: (_) => MobileEditing()),
          ChangeNotifierProvider(create: (_) => ValidSurveyQuestions()),
          ChangeNotifierProvider(create: (_) => ValidSurveyAnswers()),
          ChangeNotifierProvider(create: (_) => AccountFields()),
          ChangeNotifierProvider(create: (_) => AllUsers()),
        ],
        builder: (context, _) => MaterialApp(
          themeAnimationCurve: Curves.easeOutSine,
          navigatorKey: navKey,
          theme: AppTheme.of(context),
          debugShowCheckedModeBanner: false,
          home: LocalStorage.loggedIn() ? const HomeScreen() : const StartScreen(),
        ),
      ),
    );
  }
}

/// If you change a widget's key (using [State.setState] or a [Provider]),
/// Flutter will rebuild the whole widget!
class _AppKey extends ValueNotifier<Key> {
  _AppKey() : super(const ValueKey(null));
}
