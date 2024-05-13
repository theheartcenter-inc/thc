import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/agora/active_stream.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/num_powers.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/lerpy_hero.dart';

class LivestreamButton extends StatelessWidget {
  const LivestreamButton({required this.color, this.enabled = true, super.key});
  final Color color;
  final bool enabled;

  static Future<void> start() => navigator.currentState.push(ActiveStream.route);

  @override
  Widget build(BuildContext context) {
    final Widget child;
    switch (color) {
      case Colors.black:
        child = const SizedBox.expand();
      case Colors.transparent:
        child = const SizedBox.shrink();
      default:
        final label = switch (context.watch<NavBarSelection>().value) {
          NavBarButton.stream => 'Go Live',
          NavBarButton.watchLive || _ => 'Join',
        };

        child = AnimatedOpacity(
          duration: Durations.long1,
          opacity: enabled ? 1 : 1 / 3,
          child: SizedBox(
            width: 175,
            height: 75,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                overlayColor: const MaterialStatePropertyAll(Colors.black12),
                onTap: enabled ? start : null,
                child: Center(
                  child: Text(
                    label,
                    style: StyleText(
                      weight: 600,
                      size: 32,
                      color: enabled ? Colors.black : ThcColors.gray,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
    }

    return ChangeNotifierProvider(
      create: (_) => _LivestreamButtonData(color: color),
      child: _LivestreamLerp(child: child),
    );
  }
}

class _LivestreamLerp extends LerpyHero<ShapeDecoration> {
  const _LivestreamLerp({super.child}) : super(tag: 'go live');

  @override
  ShapeDecoration lerp(
    ShapeDecoration a,
    ShapeDecoration b,
    double t,
    HeroFlightDirection direction,
  ) {
    final tLerp = switch (direction) {
      HeroFlightDirection.push => t.cubed,
      HeroFlightDirection.pop => 1 - (1 - t).cubed,
    };
    return ShapeDecoration.lerp(a, b, tLerp)!;
  }

  @override
  ShapeDecoration fromContext(BuildContext context) {
    final color = context.watch<_LivestreamButtonData>().value;
    final radius = switch (color) {
      Colors.black => BorderRadius.zero,
      _ => BorderRadius.circular(42),
    };
    return ShapeDecoration(
      color: color,
      shape: ContinuousRectangleBorder(borderRadius: radius),
    );
  }

  @override
  Widget builder(BuildContext context, ShapeDecoration value, Widget? child) {
    return ClipPath(
      clipper: ShapeBorderClipper(shape: value.shape),
      child: DecoratedBox(
        decoration: value,
        child: child,
      ),
    );
  }
}

class _LivestreamButtonData extends ValueNotifier<Color> {
  _LivestreamButtonData({Color color = Colors.black}) : super(color);
}
