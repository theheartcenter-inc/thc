import 'package:flutter/material.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';

class FunPlaceholder extends StatelessWidget {
  const FunPlaceholder(this.label, {this.color = ThcColors.green, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final style = StyleText.mono(
      size: 32,
      weight: FontWeight.bold,
      color: color,
      shadows: [Shadow(color: colorScheme.background.withOpacity(0.5), blurRadius: 2)],
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
