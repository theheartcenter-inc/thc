import 'package:thc/firebase/firebase_setup.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/home/library/src/all_videos.dart';
import 'package:thc/home/profile/account/account_field.dart';
import 'package:thc/home/schedule/src/all_scheduled_streams.dart';
import 'package:thc/home/surveys/edit_survey/survey_editor.dart';
import 'package:thc/home/surveys/take_survey/survey.dart';
import 'package:thc/home/users/src/all_users.dart';
import 'package:thc/start/start.dart';
import 'package:thc/the_good_stuff.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final asyncSetup = <Future>[
    initFirebase(),
    loadFromLocalStorage(),
  ];
  addKeyboardShortcuts();
  await Future.wait(asyncSetup);
  await loadUser();

  runApp(const App());
}

final class App extends HookWidget {
  const App({super.key});

  static final _key = Cubit(UniqueKey());
  static void relaunch([_]) {
    navKey = GlobalKey<NavigatorState>();
    _key.value = UniqueKey();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ThcUser.instance?.isAdmin ?? false;
    final canLivestream = ThcUser.instance?.canLivestream ?? true;

    return MultiProvider(
      key: useValueListenable(_key),
      providers: [
        BlocProvider(create: (_) => AppTheme()),
        BlocProvider(create: (_) => Editing()),
        BlocProvider(create: (_) => Loading()),
        BlocProvider(create: (_) => ValidSurveyQuestions()),
        BlocProvider(create: (_) => ValidSurveyAnswers()),
        BlocProvider(create: (_) => NavBarSelection()),
        BlocProvider(create: (_) => ThcUsers(), lazy: !isAdmin),
        BlocProvider(create: (_) => ScheduledStreams(), lazy: false),
        BlocProvider(create: (_) => ThcVideos(), lazy: canLivestream),
        BlocProvider(create: (_) => UserPins(), lazy: canLivestream),
        BlocProvider(create: (_) => AccountFields()),
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
