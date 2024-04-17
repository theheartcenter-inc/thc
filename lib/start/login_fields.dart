import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thc/start/bottom_stuff.dart';
import 'package:thc/start/start.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/state_async.dart';

class LoginFields extends StatefulWidget {
  const LoginFields({super.key});

  @override
  State<LoginFields> createState() => _LoginFieldsState();
}

class _LoginFieldsState extends StateAsync<LoginFields> {
  bool expanded = false, doubleTextFields = false;
  late final node = FocusNode()..addListener(onFocus);
  void onFocus() async {
    if (!node.hasFocus) return;
    node.removeListener(onFocus);

    await sleepState(0.2, () => expanded = true);
  }

  String? username, password;

  @override
  void dispose() {
    super.dispose();
    node.dispose();
  }

  static final continueData = (
    icon: switch (defaultTargetPlatform) {
      TargetPlatform.iOS => Icons.arrow_forward_ios,
      _ => Icons.arrow_forward,
    },
    iconfg: Color.lerp(const Color(0xe0e0f0ff), Colors.white, 0.5),
    iconbg: const Color(0x20202428),
  );
  static final doneData = (
    icon: Icons.done,
    iconfg: null,
    iconbg: ThcColors.green.withOpacity(2 / 3),
  );

  static const radius = 8.0;

  @override
  Widget build(BuildContext context) {
    Widget? label;
    if (!expanded) {
      label = const DefaultTextStyle(
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: ThcColors.green,
        ),
        child: Center(child: Text('start')),
      );
    }

    final buttonPress = username?.isEmpty ?? true
        ? null
        : ([_]) {
            context.read<LoginProgressTracker>().usernameEntered();
          };
    final (:icon, :iconfg, :iconbg) = doubleTextFields ? doneData : continueData;
    final topText = Row(children: [
      if (username != null) const SizedBox(width: 50),
      Expanded(
        child: TextField(
          mouseCursor: expanded ? null : SystemMouseCursors.click,
          focusNode: node,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelStyle: const TextStyle(color: Color(0xff202428)),
            label: label,
          ),
          onChanged: (value) => setState(() => username = value),
          onSubmitted: buttonPress,
        ),
      ),
      if (username != null)
        SizedBox(
          width: 50,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 33,
                  height: 33,
                  child: ClipOval(
                    child: AnimatedOpacity(
                      opacity: buttonPress == null ? 0.5 : 1,
                      duration: Durations.short1,
                      child: ColoredBox(color: iconbg),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: buttonPress,
                  icon: Icon(icon, color: iconfg),
                )
              ],
            ),
          ),
        ),
    ]);

    final fancyField = Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: LayoutBuilder(
        builder: (context, constraints) => AnimatedContainer(
          duration: Durations.long4,
          curve: Curves.easeOutCubic,
          constraints: BoxConstraints(maxWidth: expanded ? constraints.maxWidth : 125),
          decoration: BoxDecoration(
            border: Border.fromBorderSide(
              expanded ? BorderSide.none : const BorderSide(color: ThcColors.green, width: 2.5),
            ),
            borderRadius: BorderRadius.all(Radius.circular(expanded ? radius : 0x100)),
            color: Colors.white.withAlpha(expanded ? 0x70 : 0xa0),
          ),
          child: topText,
        ),
      ),
    );

    return Column(
      children: [
        AnimatedOpacity(
          opacity: expanded ? 1 : 0,
          duration: Durations.extralong1,
          curve: Curves.easeIn,
          child: AnimatedSize(
            duration: Durations.long1,
            curve: Curves.ease,
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Color(0xff202428),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              child: expanded ? const Text('user ID') : const SizedBox(width: double.infinity),
            ),
          ),
        ),
        fancyField,
        if (expanded) const BottomStuff(),
      ],
    );
  }
}
