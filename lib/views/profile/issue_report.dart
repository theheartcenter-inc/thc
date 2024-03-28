import 'package:flutter/material.dart';
import 'package:thc/views/widgets.dart';

class IssueReport extends StatelessWidget {
  const IssueReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report an Issue')),
      body: const FunPlaceholder('report an issue', color: Colors.amber),
    );
  }
}
