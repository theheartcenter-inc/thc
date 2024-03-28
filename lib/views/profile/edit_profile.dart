import 'package:flutter/material.dart';
import 'package:thc/models/theme.dart';
import 'package:thc/views/widgets.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const FunPlaceholder('Editing the profile!', color: ThcColors.darkMagenta),
    );
  }
}
