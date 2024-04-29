import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The [Lerpy] type can be as simple as a [Color] (using [Color.lerp]),
/// or you can go wild with [Record]s, extension types, and custom classes.
abstract class LerpyHero<Lerpy> extends StatelessWidget {
  const LerpyHero({required this.tag, this.child, super.key});

  final String tag;
  final Widget? child;

  /// A way to get the [Lerpy] value using the current [BuildContext].
  ///
  /// In general, you would do this using [Theme.of] or with a [Provider].
  Lerpy fromContext(BuildContext context);
  Lerpy lerp(Lerpy a, Lerpy b, double t, HeroFlightDirection direction);
  Widget builder(BuildContext context, Lerpy value, Widget? child);

  @override
  @protected
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (_, animation, direction, context1, context2) {
        final lerpy1 = fromContext(context1);
        final lerpy2 = fromContext(context2);
        final (from, to) = switch (direction) {
          HeroFlightDirection.push => (lerpy1, lerpy2),
          HeroFlightDirection.pop => (lerpy2, lerpy1),
        };

        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return builder(context, lerp(from, to, animation.value, direction), child);
          },
          child: child,
        );
      },
      transitionOnUserGestures: true,
      child: builder(context, fromContext(context), child),
    );
  }
}

class LerpyHeroRoute<T> extends PageRoute<T> {
  LerpyHeroRoute({
    required this.builder,
    super.settings,
    super.fullscreenDialog,
    super.barrierDismissible = true,
    Color? barrierColor,
    Duration? transitionDuration,
  })  : barrierColor = barrierColor ?? Colors.black54,
        transitionDuration = transitionDuration ?? Durations.medium1;

  final WidgetBuilder builder;

  @override
  final Color barrierColor;
  @override
  final Duration transitionDuration;

  @override
  bool get opaque => barrierColor.alpha == 0xff;
  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  String get barrierLabel => barrierDismissible ? '$_label, tap to close' : _label;
  static const _label = 'dialog barrier';
}
