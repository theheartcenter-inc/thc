import 'package:flutter/material.dart';
import 'package:thc/utils/widgets/fun_placeholder.dart';

class HeartCenterInfo extends StatelessWidget {
  const HeartCenterInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Heart Center')),
      body: const FunPlaceholder('THC information'),
    );
  }
}