import 'dart:math' as math;

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:thc/agora/broadcasting/broadcast_stream.dart';
import 'package:thc/agora/channel/create_channel.dart';
import 'package:thc/agora/join_active_stream.dart';
import 'package:thc/agora/livestream_button.dart';
import 'package:thc/agora/livestream_overlay.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/home/surveys/take_survey/survey.dart';
import 'package:thc/the_good_stuff.dart';

/// {@template ActiveStream}
/// A black screen with cool button animations.
///
/// Shown when the user is creating or watching a livestream.
/// {@endtemplate}
class ActiveStream extends StatefulHookWidget {
  /// {@macro ActiveStream}
  const ActiveStream({super.key});

  static const _duration = Durations.extralong1;
  static PageRouteBuilder get route => PageRouteBuilder(
        transitionDuration: _duration,
        reverseTransitionDuration: _duration,
        pageBuilder: (_, animation, __) => BlocProvider(
          create: (_) => OverlayBloc(animation),
          child: const ActiveStream(),
        ),
      );

  @override
  State<ActiveStream> createState() => _ActiveStreamState();
}

class _ActiveStreamState extends State<ActiveStream> {
  late final bool streaming = NavBarSelection.streaming(context);

  final finishedQuestions = ThcSurvey.streamFinished.getQuestions();
  final endEarlyQuestions = ThcSurvey.streamEndedEarly.getQuestions();

  bool endedEarly = true;
  void endOnTime() {
    if (!streaming) {
      endedEarly = false;
      endStream();
    }
  }

  /// If the user was creating the livestream, we go back to the [HomeScreen].
  ///
  /// If the user was watching, we show some post-stream survey questions!
  void endStream([_, __]) async {
    context.read<OverlayBloc>().value = false;
    if (streaming) return navigator.pop();

    final (questions, type) = endedEarly
        ? (endEarlyQuestions, ThcSurvey.streamEndedEarly)
        : (finishedQuestions, ThcSurvey.streamFinished);

    navigator.pushReplacement(SurveyScreen(await questions, surveyType: type));
  }

  @override
  Widget build(BuildContext context) {
    useTimer(const Duration(seconds: 500), endOnTime);

    return const _StreamingCamera();
  }
}

class _StreamingCamera extends StatelessWidget {
  const _StreamingCamera();

  @override
  Widget build(BuildContext context) {
    final stream = NavBarSelection.streaming(context);
    switch (stream) {
      case true:
        return const CreateChannelPage();
      case false:
        return const JoinActiveStream();
    }
  }
}

class _ViewCount extends StatelessWidget {
  const _ViewCount();

  @override
  Widget build(BuildContext context) {
    final peopleWatching = math.Random().nextBool() ? 69 : 420;
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Text(
        '$peopleWatching watching',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

/// Whether this button is shown is determined by the [OverlayBloc].
///
/// Unlike the rest of the overlay, it disappears by sliding off the screen.
class _EndButton extends StatelessWidget {
  const _EndButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const style = ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(Colors.red),
      foregroundColor: WidgetStatePropertyAll(Colors.white),
      overlayColor: WidgetStatePropertyAll(Colors.white10),
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 25, vertical: 20)),
      shape: WidgetStatePropertyAll(StadiumBorder()),
    );

    return FilledButton(
      onPressed: onPressed,
      onHover: context.read<OverlayBloc>().hover,
      style: style,
      child: const Text('End', style: TextStyle(size: 18)),
    );
  }
}
