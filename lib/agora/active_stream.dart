import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:thc/agora/livestream_button.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/home/surveys/take_survey/survey.dart';
import 'package:thc/utils/app_config.dart';
import 'package:thc/utils/bloc.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/widgets/state_async.dart';

/// {@template ActiveStream}
/// A black screen with cool button animations.
///
/// Shown when the user is creating or watching a livestream.
/// {@endtemplate}
class ActiveStream extends StatefulWidget {
  /// {@macro ActiveStream}
  const ActiveStream({super.key});

  static const _duration = Durations.extralong1;
  static PageRouteBuilder get route => PageRouteBuilder(
        transitionDuration: _duration,
        reverseTransitionDuration: _duration,
        pageBuilder: (_, animation, __) => BlocProvider(
          create: (_) => StreamOverlayFadeIn(animation),
          child: const ActiveStream(),
        ),
      );

  @override
  State<ActiveStream> createState() => _ActiveStreamState();
}

class _ActiveStreamState extends StateAsync<ActiveStream> {
  /// The [_EndButton] appears when you tap the screen,
  /// then goes away after a few seconds, thanks to this timer.
  Timer? timer;
  void setTimer([_]) {
    timer?.cancel();
    if (!overlayVisible) setState(() => overlayVisible = true);
    timer = Timer(
      const Duration(seconds: 4),
      () => safeState(() => overlayVisible = false),
    );
  }

  /// Used to determine whether [finishedQuestions] or [endEarlyQuestions]
  /// are shown. Will probably change once Agora is up and running.
  late final Timer endStreamTimer;

  @override
  void animate() async {
    endStreamTimer = Timer(const Duration(seconds: 10), endStream);
    Future.delayed(Durations.long2, setTimer);
  }

  /// Determines whether [_EndButton] is shown.
  ///
  /// (Also makes [_ViewCount] more opaque.)
  bool overlayVisible = true;
  bool buttonHovered = false;

  /// Automatically hide the overlay when you move your mouse off the screen.
  void mouseOffScreen([_]) async {
    timer?.cancel();

    await sleep(0.01); // wait for buttonHovered to update
    if (buttonHovered) return;

    safeState(() => overlayVisible = false);
  }

  /// We're trying to make a mobile app,
  /// so showing/hiding the overlay should be able to operate via touch.
  void onTap() {
    if (timer?.isActive ?? false) {
      timer?.cancel();
      setState(() => overlayVisible = false);
    } else {
      setTimer();
    }
  }

  /// Prevents the [_EndButton] from disappearing when you
  /// move your mouse to click it, cause that would be weird.
  void buttonHover(bool isHovered) {
    buttonHovered = isHovered;
    if (isHovered) timer?.cancel();
  }

  final finishedQuestions = ThcSurvey.streamFinished.getQuestions();
  final endEarlyQuestions = ThcSurvey.streamEndedEarly.getQuestions();

  void endStream({bool endedEarly = false}) async {
    context.read<StreamOverlayFadeIn>().value = false;
    if (NavBarSelection.of(context, listen: false).streaming) {
      return navigator.pop();
    }

    final (questions, type) = endedEarly
        ? (endEarlyQuestions, ThcSurvey.streamEndedEarly)
        : (finishedQuestions, ThcSurvey.streamFinished);

    navigator.pushReplacement(SurveyScreen(await questions, surveyType: type));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdaptiveInput(
        desktop: (onHover: setTimer, mouseOffScreen: mouseOffScreen),
        mobile: (onTap: onTap),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            const LivestreamButton(color: Colors.black),
            StreamOverlay(overlayVisible ? 1.0 : 0.25, child: const _ViewCount()),
            StreamOverlay(overlayVisible ? 1.0 : 0.0, child: const _StreamingCamera()),
            NavBar.of(context, belowPage: true),
          ],
        ),
      ),
      floatingActionButton: StreamOverlay(
        overlayVisible ? Offset.zero : const Offset(0, 2),
        child: _EndButton(
          onPressed: () {
            endStreamTimer.cancel();
            endStream(endedEarly: true);
          },
          onHover: buttonHover,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

/// {@template AdaptiveInput}
/// Tracks the mouse on desktop platforms, and recognizes tapping on mobile.
/// {@endtemplate}
class AdaptiveInput extends StatelessWidget {
  /// {@macro AdaptiveInput}
  const AdaptiveInput({
    required this.desktop,
    required this.mobile,
    required this.child,
    super.key,
  });

  final ({VoidCallback onHover, VoidCallback mouseOffScreen}) desktop;
  final ({VoidCallback onTap}) mobile;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (mobileDevice) {
      return GestureDetector(
        onTap: mobile.onTap,
        child: child,
      );
    } else {
      return MouseRegion(
        onHover: (_) => desktop.onHover(),
        onExit: (_) => desktop.mouseOffScreen(),
        child: child,
      );
    }
  }
}

/// {@template views.create_livestream.StreamingCamera}
/// Currently just a placeholder.
/// {@endtemplate}
class _StreamingCamera extends StatelessWidget {
  /// {@macro views.create_livestream.StreamingCamera}
  const _StreamingCamera();

  @override
  Widget build(BuildContext context) {
    final enjoying = NavBarSelection.of(context).streaming ? 'filming' : 'watching';

    return Center(
      child: Text(
        "(pretend you're $enjoying a very cool livestream)",
        style: const TextStyle(color: Colors.white70),
      ),
    );
  }
}

/// {@template ViewCount}
/// The view has an [AnimatedOpacity] based on
/// whether the overlay is being shown.
/// {@endtemplate}
class _ViewCount extends StatelessWidget {
  /// {@macro ViewCount}
  const _ViewCount();

  int get peopleWatching => math.Random().nextBool() ? 69 : 420;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Text(
        '$peopleWatching watching',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

/// Whether this button is shown is determined by [_ActiveStreamState.overlayVisible].
///
/// Unlike the rest of the overlay, it disappears by sliding off the screen.
class _EndButton extends FilledButton {
  const _EndButton({required super.onPressed, required super.onHover})
      : super(style: _style, child: const Text('End', style: TextStyle(fontSize: 18)));

  static const _style = ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(Colors.red),
    foregroundColor: WidgetStatePropertyAll(Colors.white),
    overlayColor: WidgetStatePropertyAll(Colors.white10),
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 25, vertical: 20)),
    shape: WidgetStatePropertyAll(StadiumBorder()),
  );
}

/// {@template StreamOverlay}
/// Without this widget, things would be kind of ugly:
///
/// ```dart
/// AnimatedOpacity(
///   opacity: overlayVisible ? 1 : 0,
///   duration: Durations.medium1,
///   child: AnimatedOpacity(
///     opacity: fadeIn ? 1 : 0,
///     duration: Durations.medium1,
///     child: _ViewCount(),
///   )
/// )
/// ```
///
/// Not a big fan of the double-nested [AnimatedOpacity].
///
/// But since [_EndButton] disappears by sliding, we need
/// [value] to have a more flexible type.
/// {@endtemplate}
class StreamOverlay extends StatelessWidget {
  /// {@macro StreamOverlay}
  const StreamOverlay(this.value, {super.key, required this.child})
      : assert(value is Offset || value is double);

  /// Since the buttons disappear by sliding, we need
  /// [value] to have a flexible type.
  final dynamic value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const duration = Durations.medium1;

    final child = AnimatedOpacity(
      opacity: context.watch<StreamOverlayFadeIn>().value ? 1 : 0,
      duration: duration,
      child: this.child,
    );

    return switch (value) {
      final double opacity => AnimatedOpacity(
          opacity: opacity,
          duration: duration,
          child: child,
        ),
      final Offset offset => AnimatedSlide(
          offset: offset,
          duration: duration,
          curve: Curves.ease,
          child: child,
        ),
      _ => throw TypeError(),
    };
  }
}

/// Starts out `false` when "Go Live" is pressed
/// and becomes `true` once the animation is done.
///
/// This is implemented as a [Cubit] so that we can fetch the value
/// from the [BuildContext] rather than passing the argument
/// all the way down the widget tree.
class StreamOverlayFadeIn extends Cubit<bool> {
  StreamOverlayFadeIn(Animation<double> animation) : super(false) {
    animation.addStatusListener((status) async {
      final complete = status == AnimationStatus.completed;
      if (complete) await Future.delayed(Durations.medium1);
      value = complete;
    });
  }
}
