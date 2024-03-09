import 'package:flutter/material.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/widgets.dart';

class VideoLibrary extends StatelessWidget {
  const VideoLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return FunPlaceholder('video library', color: context.colorScheme.secondary);
  }
}
