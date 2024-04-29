import 'package:flutter/widgets.dart';

class ClipHeight extends StatelessWidget {
  const ClipHeight({
    this.alignment = Alignment.topCenter,
    required this.childHeight,
    required this.child,
    super.key,
  });
  final AlignmentGeometry alignment;
  final double childHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => FittedBox(
        alignment: alignment,
        fit: BoxFit.fitWidth,
        child: SizedBox(
          width: constraints.maxWidth,
          height: childHeight,
          child: child,
        ),
      ),
    );
  }
}
