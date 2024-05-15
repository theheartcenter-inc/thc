import 'package:flutter/material.dart';
import 'package:thc/utils/widgets/lerpy_hero/data_widget.dart';

/// The [T] type can be as simple as a [Color] (using [Color.lerp]),
/// or you can go wild with [Record]s, extension types, and custom classes.
///
/// {@template LerpyHero.extends_Widget}
/// We're extending [Widget] instead of [StatelessWidget] so that we can have
/// a private [_build] method.
/// {@endtemplate}
abstract class LerpyHero<T> extends Widget {
  const LerpyHero({
    required this.data,
    this.transitionOnUserGestures = true,
    this.tag,
    this.child,
    super.key,
  });

  const factory LerpyHero.create({
    required HeroLerp<T> lerp,
    required ValueWidgetBuilder<T> builder,
    required T data,
    bool transitionOnUserGestures,
    String? tag,
    Widget? child,
    Key? key,
  }) = _CreateLerpyHero;

  final T data;
  final String? tag;
  final Widget? child;
  final bool transitionOnUserGestures;

  /// "Lerp" is short for "linear interpolation".
  ///
  /// But feel free to do a non-linear interpolation if you want :)
  T lerp(T a, T b, double t, HeroFlightDirection direction);

  /// This is a [ValueWidgetBuilder]—it creates a widget
  /// based on the current progress of the animation.
  Widget builder(BuildContext context, T value, Widget? child);

  @override
  StatelessElement createElement() => _LerpyHeroElement(this);

  Widget _build(BuildContext context) =>
      DataWidget<T>(data: data, child: Builder(builder: _buildHero));

  Widget _buildHero(BuildContext context) {
    return Hero(
      tag: tag ?? '$LerpyHero<$T>',
      flightShuttleBuilder: (_, animation, direction, context1, context2) {
        final lerpy1 = DataWidget.read<T>(context1);
        final lerpy2 = DataWidget.read<T>(context2);
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
      child: builder(context, DataWidget.read<T>(context), child),
    );
  }
}

typedef HeroLerp<T> = T Function(T a, T b, double t, HeroFlightDirection direction);

class _CreateLerpyHero<T> extends LerpyHero<T> {
  const _CreateLerpyHero({
    required HeroLerp<T> lerp,
    required ValueWidgetBuilder<T> builder,
    required super.data,
    super.transitionOnUserGestures = true,
    super.tag,
    super.child,
    super.key,
  })  : _lerp = lerp,
        _builder = builder;

  final HeroLerp<T> _lerp;
  final ValueWidgetBuilder<T> _builder;

  @override
  T lerp(T a, T b, double t, HeroFlightDirection direction) => _lerp(a, b, t, direction);

  @override
  Widget builder(BuildContext context, T value, Widget? child) {
    return _builder(context, value, child);
  }
}

/// {@macro LerpyHero.extends_Widget}
class _LerpyHeroElement extends ComponentElement implements StatelessElement {
  /// {@macro LerpyHero.extends_Widget}
  _LerpyHeroElement(super.widget);

  @override
  Widget build() => (widget as LerpyHero)._build(this);
}

/// Enables hero transitions to/from dialogs.
class LerpyHeroRoute<T> extends PageRoute<T> {
  /// Enables hero transitions to/from dialogs.
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
