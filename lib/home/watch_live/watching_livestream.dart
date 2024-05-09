import 'dart:async';

import 'package:flutter/material.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/home/surveys/take_survey/survey.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/widgets/fun_placeholder.dart';

class WatchingLivestream extends StatefulWidget {
  const WatchingLivestream({super.key});

  @override
  State<WatchingLivestream> createState() => _WatchingLivestreamState();
}

class _WatchingLivestreamState extends State<WatchingLivestream> {
  late final Timer timer;
  bool endedEarly = false;

  void endStream() async {
    final questions = endedEarly
        ? ThcSurvey.streamEndedEarly.getQuestions()
        : ThcSurvey.streamFinished.getQuestions();
    navigator.pushReplacement(SurveyScreen(await questions));
  }

  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(seconds: 5), endStream);
  }

  @override
  Widget build(BuildContext context) {
    const placeholder = BottomNavigationBarItem(icon: SizedBox.shrink(), label: '');
    return Scaffold(
      backgroundColor: Colors.black,
      body: const FunPlaceholder('Watching a livestream!', color: Colors.grey),
      bottomNavigationBar: BottomNavigationBar(
        useLegacyColorScheme: false,
        backgroundColor: Colors.black,
        unselectedLabelStyle: const StyleText(color: Colors.white70, weight: 600),
        onTap: (_) {
          timer.cancel();
          endedEarly = true;
          endStream();
        },
        items: const [
          placeholder,
          placeholder,
          BottomNavigationBarItem(
            icon: Icon(Icons.logout, color: Colors.red, size: 24),
            label: 'leave',
          ),
        ],
      ),
    );
  }
}
