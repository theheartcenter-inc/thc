import 'package:flutter/material.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/widgets.dart';

class CreateLivestream extends StatelessWidget {
  const CreateLivestream({super.key});

  @override
  Widget build(BuildContext context) {
    return FunPlaceholder('make a livestream', color: context.colorScheme.tertiary);
  }
}
