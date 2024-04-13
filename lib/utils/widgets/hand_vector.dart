import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:svg_path_parser/svg_path_parser.dart';

String svgPath(String svgFilename) {
  final svg = File('assets/svg_files/$svgFilename.svg').readAsStringSync();
  return svg.split('d="').last.split('/>').first.split('"').first;
}

class SvgPainter extends CustomPainter {
  const SvgPainter({required this.fileName, required this.color});

  final String fileName;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = color;

    final Path path = parseSvgPath(svgPath(fileName));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
