import 'package:flutter/widgets.dart';

/// {@template ClipHeight}
/// Similar to a [SingleChildScrollView] with [NeverScrollableScrollPhysics],
/// but more efficient!
///
/// [FittedBox] is great for when you want to cut off part of a widget
/// (e.g. during an animation) without causing any layout errors.
/// {@endtemplate}
class ClipHeight extends StatelessWidget {
  /// {@macro ClipHeight}
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
