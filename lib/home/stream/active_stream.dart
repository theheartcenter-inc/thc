import 'dart:async';
import 'dart:math';

import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/credentials/credentials.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/utils/bloc.dart';
import 'package:thc/utils/app_config.dart';
import 'package:thc/utils/widgets/state_async.dart';

class ActiveStream extends StatefulWidget {
  const ActiveStream({super.key});

  @override
  State<ActiveStream> createState() => _ActiveStreamState();
}

class _ActiveStreamState extends StateAsync<ActiveStream> {
  /// The buttons appear when you tap the screen,
  /// then go away after a few seconds, thanks to this timer.
  Timer? timer;
  void setTimer([_]) {
    timer?.cancel();
    if (!overlayVisible) safeState(() => overlayVisible = true);
    timer = Timer(
      const Duration(seconds: 4),
      () => safeState(() => overlayVisible = false),
    );
  }

  final AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
      appId: AgoraCredentials.id,
      channelName: AgoraCredentials.channel,
      tempToken: AgoraCredentials.token,
    ),
  );

  @override
  void animate() async {
    if (useInternet) client.initialize();
    sleep(0.5, then: setTimer);
  }

  /// Determines whether buttons are shown.
  ///
  /// (Also makes [_ViewCount] more opaque.)
  bool overlayVisible = true;
  bool buttonHovered = false;

  /// Prevents the buttons from disappearing when you
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
            if (useInternet)
              AgoraVideoViewer(
                client: client,
                layoutType: Layout.floating,
                enableHostControls: true,
              )
            else
              const Center(
                child: Text('making a livestream!', style: TextStyle(color: Colors.white)),
              ),
            NavBar.of(context, belowPage: true),
          ],
        ),
      ),
      floatingActionButton: StreamOverlay(
        overlayVisible ? Offset.zero : const Offset(0, 2),
        child: AgoraVideoButtons(client: client),
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
    return Hero(
      tag: 'go live',
      child: Transform.scale(
        scale: 1.25,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(Radius.elliptical(50, 30)),
          ),
          child: SizedBox.expand(),
        ),
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
      final Offset offset =>
        AnimatedSlide(offset: offset, duration: duration, curve: Curves.ease, child: child),
      final double opacity => AnimatedOpacity(opacity: opacity, duration: duration, child: child),
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
