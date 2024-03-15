import 'package:flutter/material.dart';
import 'package:thc/models/theme.dart';

class FunPlaceholder extends StatelessWidget {
  const FunPlaceholder(this.label, {this.color, super.key});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colorScheme = theme.colorScheme;
    final color = this.color ?? colorScheme.primary;
    final style = TextStyle(
      color: color,
      fontFamily: 'Consolas',
      fontFamilyFallback: const ['Courier New', 'Courier', 'monospace'],
      fontSize: 32,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(color: colorScheme.background.withOpacity(0.5), blurRadius: 2),
      ],
    );

    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(label, textAlign: TextAlign.center, style: style),
      ),
    );
  }
}
