import 'package:flutter/material.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/fun_placeholder.dart';

class VideoLibrary extends StatelessWidget {
  const VideoLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    return FunPlaceholder('video library', color: context.colorScheme.secondary);
  }
}
