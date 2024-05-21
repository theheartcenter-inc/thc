import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/start/src/login_progress.dart';
import 'package:thc/start/src/start_theme.dart';
import 'package:thc/start/src/za_hando.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StartTheme(
      child: ChangeNotifierProvider(
        create: LoginProgressTracker.create,
        child: const ZaHando(),
      ),
    );
  }
}
