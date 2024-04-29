import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/home/stream/create_livestream.dart';
import 'package:thc/utils/app_config.dart';
import 'package:thc/utils/bloc.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/state_async.dart';

class ActiveStream extends StatefulWidget {
  const ActiveStream({super.key});

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

  @override
  void animate() => sleep(0.5, then: setTimer);

  /// Determines whether [_EndButton] is shown.
  ///
  /// (Also makes [_ViewCount] more opaque.)
  bool overlayVisible = true;
  bool buttonHovered = false;

  /// Prevents the [_EndButton] from disappearing when you
  /// move your mouse to click it, cause that would be weird.
  void buttonHover(bool isHovered) {
    buttonHovered = isHovered;
    if (isHovered) timer?.cancel();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdaptiveInput(
        desktop: (onHover: setTimer, mouseOffScreen: mouseOffScreen),
        mobile: (onTap: onTap),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            const _Backdrop(),
            StreamOverlay(overlayVisible ? 1.0 : 0.25, child: const _ViewCount()),
            StreamOverlay(overlayVisible ? 1.0 : 0.0, child: const _StreamingCamera()),
            NavBar.of(context, belowPage: true),
          ],
        ),
      ),
      floatingActionButton: StreamOverlay(
        overlayVisible ? Offset.zero : const Offset(0, 2),
        child: _EndButton(onPressed: navigator.pop, onHover: buttonHover),
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

/// {@template Backdrop}
/// The [Hero] widget gives the "Go Live" button a fun little animation
/// as it expands into this black backdrop.
/// {@endtemplate}
class _Backdrop extends StatelessWidget {
  /// {@macro Backdrop}
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: context.editScheme(secondary: Colors.black),
      child: const GoLive(),
    );
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
    return const Center(
      child: Text(
        "(pretend you're filming a very cool livestream)",
        style: TextStyle(color: Colors.white70),
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

  int get peopleWatching => Random().nextBool() ? 69 : 420;

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
    backgroundColor: MaterialStatePropertyAll(Colors.red),
    foregroundColor: MaterialStatePropertyAll(Colors.white),
    overlayColor: MaterialStatePropertyAll(Colors.white10),
    padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 25, vertical: 20)),
    shape: MaterialStatePropertyAll(StadiumBorder()),
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
      opacity: context.watch<StreamOverlayFadeIn>().state ? 1 : 0,
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
    animation.addStatusListener((status) => emit(status == AnimationStatus.completed));
  }
}
