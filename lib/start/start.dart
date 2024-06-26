import 'package:thc/start/src/login_progress.dart';
import 'package:thc/start/src/start_theme.dart';
import 'package:thc/start/src/za_hando.dart';
import 'package:thc/the_good_stuff.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: LoginProgressTracker.create,
      child: const StartTheme(child: ZaHando()),
    );
  }
}
