import 'package:thc/the_good_stuff.dart';

class LivestreamOverlay extends StatelessWidget {
  const LivestreamOverlay({super.key, required this.whenHidden, required this.child})
      : assert(whenHidden is Offset || whenHidden is double);

  /// Since stuff can disappear either by fading or sliding,
  /// we need [whenHidden] to have a flexible type.
  final dynamic whenHidden;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final overlay = context.watch<OverlayBloc>();
    const duration = Durations.medium1;

    final child = AnimatedOpacity(
      opacity: overlay.fadeIn ? 1 : 0,
      duration: duration,
      child: this.child,
    );

    return switch (whenHidden) {
      final double opacity => AnimatedOpacity(
          opacity: overlay.value ? 1 : opacity,
          duration: duration,
          child: child,
        ),
      final Offset offset => AnimatedSlide(
          offset: overlay.value ? Offset.zero : offset,
          duration: duration,
          curve: Curves.ease,
          child: child,
        ),
      _ => throw TypeError(),
    };
  }
}

/// {@template AdaptiveInput}
/// Tracks the mouse on desktop platforms, and recognizes tapping on mobile.
/// {@endtemplate}
class OverlayController extends StatelessWidget {
  /// {@macro AdaptiveInput}
  const OverlayController({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    late final overlay = context.read<OverlayBloc>();

    if (mobileDevice) return GestureDetector(onTap: overlay.tap, child: child);

    if (kIsWeb) {
      // hiding the mouse cursor works properly on web platforms,
      // so we use context.watch() here to trigger rebuilds when the visibility changes.
      final overlay = context.watch<OverlayBloc>();
      return MouseRegion(
        onHover: overlay.setTimer,
        onExit: overlay.hide,
        cursor: overlay.value ? MouseCursor.defer : SystemMouseCursors.none,
        child: child,
      );
    }

    return MouseRegion(
      onHover: overlay.setTimer,
      onExit: overlay.hide,
      child: child,
    );
  }
}

/// {@template OverlayBloc}
/// Controls whether the [LivestreamOverlay] widgets are visible.
/// {@endtemplate}
class OverlayBloc extends Cubit<bool> {
  /// {@macro OverlayBloc}
  OverlayBloc(Animation<double> animation) : super(false) {
    void onStatusChange(AnimationStatus status) async {
      final bool complete = status == AnimationStatus.completed;
      if (complete) {
        await Future.delayed(Durations.medium1);
        setTimer();
      }
      fadeIn = complete;
    }

    animation.addStatusListener(onStatusChange);
  }

  bool _fadeIn = false;
  bool get fadeIn => _fadeIn;
  set fadeIn(bool newVal) {
    if (_fadeIn == newVal) return;
    _fadeIn = newVal;
    notifyListeners();
  }

  bool _hovering = false;

  /// If the mouse cursor is hovering on a button, we'll skip hiding the overlay
  /// when it times out.
  void hover(bool hovering) => _hovering = hovering;

  void hide([_]) async {
    await Future.delayed(const Duration(milliseconds: 35));
    if (_hovering) return;
    value = false;
  }

  Timer _timer = Timer(Durations.short1, () {});

  void setTimer([_]) async {
    value = true;
    _timer.cancel();
    _timer = Timer(const Duration(seconds: 4), hide);
  }

  void tap() => value ? hide() : setTimer();

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
