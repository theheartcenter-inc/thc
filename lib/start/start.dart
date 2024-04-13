import 'package:flutter/material.dart';
import 'package:thc/utils/widgets/hand_vector.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: ZaHando(),
        ),
      ),
    );
  }
}

class ZaHando extends StatelessWidget {
  const ZaHando({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: FittedBox(
        child: TweenAnimationBuilder(
          duration: const Duration(seconds: 5),
          curve: Curves.fastOutSlowIn,
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (_, value, __) {
            final hsv = HSVColor.fromAHSV(1.0, 180 - value * 60, 1 - value * 0.75, value * 0.8);
            final sunHSV = HSVColor.fromAHSV(1, value * 30 + 20, 1, (value + 1) / 2);
            final innerSunHSV = HSVColor.fromAHSV(1, value * 30 + 30, 1, (value + 1) / 2);
            final scale = 20 * (1 - value) + 1;
            final offset = Offset(0, scale * 50 - 150);
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Transform.scale(
                  scale: scale,
                  child: CustomPaint(
                    size: const Size(600, 800),
                    painter: SvgPainter(color: hsv.toColor(), fileName: 'thc_logo'),
                  ),
                ),
                Transform.translate(
                  offset: offset,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            innerSunHSV.toColor(),
                            HSVColor.lerp(innerSunHSV, sunHSV, 0.25)!.toColor(),
                            sunHSV.toColor(),
                          ],
                          // stops: const [0.5, 1],
                        ),
                        shape: BoxShape.circle),
                    child: SizedBox.fromSize(size: const Size.square(200)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
