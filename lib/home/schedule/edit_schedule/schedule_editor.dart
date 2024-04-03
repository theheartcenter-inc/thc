import 'package:flutter/material.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/fun_placeholder.dart';

class ScheduleEditor extends StatelessWidget {
  const ScheduleEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return const FunPlaceholder('schedule a livestream!', color: ThcColors.dullBlue);
  }
}
