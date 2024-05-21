import 'package:flutter/material.dart';
import 'package:thc/agora/active_stream.dart';
import 'package:thc/home/home_screen.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/num_powers.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/lerpy_hero/lerpy_hero.dart';

/// {@template LivestreamButton}
/// Technically, this widget isn't always a button—it animates back and forth
/// between a button and the black livestream backdrop.
///
/// In the lobby screen, it's a tiny transparent dot in the middle of the page
/// that expands into the livestream backdrop when the stream starts.
/// {@endtemplate}
class LivestreamButton extends StatelessWidget {
  /// {@macro LivestreamButton}
  const LivestreamButton({required this.color, this.enabled = true, super.key});
  final Color color;
  final bool enabled;

  static Future<void> start() => navigator.currentState.push(ActiveStream.route);

  @override
  Widget build(BuildContext context) {
    late final button = AnimatedOpacity(
      duration: Durations.long1,
      opacity: enabled ? 1 : 1 / 3,
      child: SizedBox(
        width: 175,
        height: 75,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            overlayColor: const WidgetStatePropertyAll(Colors.black12),
            onTap: enabled ? start : null,
            child: Center(
              child: Text(
                NavBarSelection.of(context).streaming ? 'Go Live' : 'Join',
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

    return LerpyHero<ShapeDecoration>.create(
      lerp: (a, b, t, direction) {
        t = switch (direction) {
          HeroFlightDirection.push => t.cubed,
          HeroFlightDirection.pop => 1 - (1 - t).cubed,
        };
        return ShapeDecoration.lerp(a, b, t)!;
      },
      builder: (context, value, child) => ClipPath(
        clipper: ShapeBorderClipper(shape: value.shape),
        child: DecoratedBox(decoration: value, child: child),
      ),
      data: ShapeDecoration(
        color: color,
        shape: ContinuousRectangleBorder(
          borderRadius: switch (color) {
            Colors.black => BorderRadius.zero,
            _ => BorderRadius.circular(42),
          },
        ),
      ),
      child: switch (color) {
        Colors.black => const SizedBox.expand(),
        Colors.transparent => const SizedBox.shrink(),
        _ => button,
      },
    );
  }
}
