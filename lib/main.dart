import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/firebase/firebase_setup.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/home/profile/account/account_field.dart';
import 'package:thc/home/surveys/edit_survey/survey_editor.dart';
import 'package:thc/home/surveys/take_survey/survey.dart';
import 'package:thc/start/start.dart';
import 'package:thc/utils/bloc.dart';
import 'package:thc/utils/keyboard_shortcuts.dart';
import 'package:thc/utils/local_storage.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  addKeyboardShortcuts();

  await Future.wait([
    initFirebase(),
    loadFromLocalStorage(),
  ]);
  await ThcUser.loadfromLocalStorage();

  runApp(const App());
}

class App extends StatelessWidget {
  const App() : super(key: null);

  static final _key = _AppKey();
  static void relaunch() {
    navKey = GlobalKey<NavigatorState>();
    _key.emit(UniqueKey());
  }

  static bool sliders = false;

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
          themeAnimationCurve: Curves.easeOutSine,
          navigatorKey: navKey,
          theme: AppTheme.of(context),
          debugShowCheckedModeBanner: false,
          home: sliders
              ? const FontSliders()
              : LocalStorage.loggedIn()
                  ? const HomeScreen()
                  : const StartScreen(),
        ),
      ),
    );
  }
}

class _AppKey extends Cubit<Key> {
  _AppKey() : super(UniqueKey());
}

class FontSliders extends StatefulWidget {
  const FontSliders({super.key});

  @override
  State<FontSliders> createState() => _FontSlidersState();
}

class _FontSlidersState extends State<FontSliders> {
  bool useBetterFont = false;

  double weight = 100;

  @override
  Widget build(BuildContext context) {
    late final fontWeight = FontWeight.lerp(
      FontWeight.w100,
      FontWeight.w900,
      (weight / 100 - 1) / 8,
    )!;

    final style = useBetterFont
        ? StyleText(weight: weight)
        : TextStyle(fontFamily: 'Segoe UI', fontWeight: fontWeight);

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: SizedBox(
            width: 400,
            child: SwitchListTile(
              title: const Text(
                'use better font',
                textAlign: TextAlign.center,
                style: StyleText(size: 20, color: Colors.white),
              ),
              value: useBetterFont,
              onChanged: (value) => setState(() => useBetterFont = value),
            ),
          ),
        ),
      ),
      body: Center(
        child: DefaultTextStyle(
          style: const TextStyle(fontSize: 24, color: Colors.black),
          child: SizedBox(
            width: 500,
            child: Column(
              children: [
                const Spacer(),
                Text(
                  'If only we had 5 or 10 more years,\n'
                  'we might have finally made that trip\n'
                  "we've been talking about.",
                  textAlign: TextAlign.center,
                  style: style,
                ),
                const Spacer(),
                Slider(
                  min: 100,
                  max: 900,
                  divisions: useBetterFont ? null : 8,
                  value: weight,
                  onChanged: (newWeight) => setState(() => weight = newWeight),
                ),
                Text('font weight: ${weight.round()}'),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
