import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/models/bloc.dart';
import 'package:thc/models/credentials/credentials.dart';
import 'package:thc/models/navigation.dart';
import 'package:thc/views/widgets.dart';

final bool isMobile = switch (Platform.operatingSystem) {
  'ios' || 'android' => true,
  _ => false,
};

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
    if (!overlayVisible) safeState(() => overlayVisible = true);
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
            _StreamingCamera(overlayVisible),
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

class AdaptiveInput extends StatelessWidget {
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
    if (isMobile) {
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

/// {@template views.create_livestream.Backdrop}
/// The [Hero] widget gives the "Go Live" button a fun little animation
/// as it expands into this black backdrop.
/// {@endtemplate}
class _Backdrop extends StatelessWidget {
  /// {@macro views.create_livestream.Backdrop}
  const _Backdrop();

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'go live',
      child: Transform.scale(
        scale: 1.1,
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

/// {@template views.create_livestream.StreamingCamera}
/// Currently just a placeholder.
/// {@endtemplate}
class _StreamingCamera extends StatelessWidget {
  /// {@macro views.create_livestream.StreamingCamera}
  const _StreamingCamera(this.overlayVisible);
  final bool overlayVisible;

  @override
  Widget build(BuildContext context) {
    final bool streamingForReal = isMobile;

    if (streamingForReal) return const _AgoraLivestream();

    return StreamOverlay(
      overlayVisible ? 1.0 : 0.0,
      child: const Center(
        child: Text(
          "(pretend you're filming a very cool livestream)",
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}

class _AgoraLivestream extends StatefulWidget {
  const _AgoraLivestream();

  @override
  State<_AgoraLivestream> createState() => _AgoraLivestreamState();
}

class _AgoraLivestreamState extends StateAsync<_AgoraLivestream> {
  late final AgoraClient client;
  @override
  void animate() async {
    client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: AgoraCredentials.id,
        channelName: AgoraCredentials.channel,
        tempToken: AgoraCredentials.token,
      ),
    )..initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AgoraVideoViewer(
          client: client,
          layoutType: Layout.floating,
          enableHostControls: true,
        ),
        AgoraVideoButtons(client: client),
      ],
    );
  }
}

/// {@template views.create_livestream.ViewCount}
/// The view has an [AnimatedOpacity] based on
/// whether the overlay is being shown.
/// {@endtemplate}
class _ViewCount extends StatelessWidget {
  /// {@macro views.create_livestream.ViewCount}
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
    padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 25, vertical: 18)),
    shape: MaterialStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(100))),
    ),
  );
}

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
class StreamOverlay extends StatelessWidget {
  const StreamOverlay(this.value, {super.key, required this.child})
      : assert(value is Offset || value is double);

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
