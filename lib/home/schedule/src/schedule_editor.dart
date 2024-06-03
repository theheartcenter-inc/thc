import 'package:flutter/material.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/placeholders.dart';

class ScheduleEditor extends StatelessWidget {
  const ScheduleEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const FunPlaceholder('change livestream schedule!', color: ThcColors.dullBlue),
    );
  }
}
