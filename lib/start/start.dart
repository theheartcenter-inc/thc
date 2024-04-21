import 'package:flutter/material.dart';
import 'package:thc/start/src/progress_tracker.dart';
import 'package:thc/start/src/start_theme.dart';
import 'package:thc/start/src/za_hando.dart';
import 'package:thc/utils/bloc.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StartTheme(
      child: BlocProvider(
        create: LoginProgressTracker.create,
        child: const ZaHando(),
      ),
    );
  }
}
