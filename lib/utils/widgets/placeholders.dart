import 'package:thc/the_good_stuff.dart';

class FunPlaceholder extends StatelessWidget {
  const FunPlaceholder(this.label, {this.color = ThcColors.green, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = ThcColors.of(context);
    final style = TextStyle.mono(
      size: 32,
      weight: 700,
      color: color,
      shadows: [Shadow(color: colors.surface.withOpacity(0.5), blurRadius: 2)],
    );

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(label, textAlign: TextAlign.center, style: style),
    );
  }
}

class PlaceholderImage extends StatelessWidget {
  const PlaceholderImage({required this.width, super.key});
  final double width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox.square(
        dimension: width,
        child: const ClipOval(
          child: FittedBox(
            fit: BoxFit.cover,
            child: Image(image: AssetImage('assets/profile_placeholder.jpg')),
          ),
        ),
      ),
    );
  }
}
