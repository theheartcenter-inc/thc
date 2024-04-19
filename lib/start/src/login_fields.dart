import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thc/start/src/bottom_stuff.dart';
import 'package:thc/start/src/progress_tracker.dart';
import 'package:thc/start/src/start_theme.dart';
import 'package:thc/start/src/za_hando.dart';
import 'package:thc/utils/theme.dart';

class LoginFields extends StatefulWidget {
  const LoginFields({super.key});

  @override
  State<LoginFields> createState() => _LoginFieldsState();
}

class _LoginFieldsState extends State<LoginFields> {
  Alignment buttonAlignment = Alignment.topRight;
  late final usernameNode = FocusNode()..addListener(onFocus);
  final passwordNode = FocusNode();
  void onFocus() async {
    final align = usernameNode.hasFocus ? Alignment.topRight : Alignment.bottomRight;
    setState(() => buttonAlignment = align);
  }

  String? username, password;

  @override
  void dispose() {
    super.dispose();
    usernameNode.dispose();
    passwordNode.dispose();
  }

  static final continueData = (
    icon: switch (defaultTargetPlatform) {
      TargetPlatform.iOS => Icons.arrow_forward_ios,
      _ => Icons.arrow_forward,
    },
    iconfg: Color.lerp(StartColors.lightContainer, Colors.white, 0.5),
    iconbg: StartColors.bg12,
  );
  static const doneData = (
    icon: Icons.done,
    iconfg: null,
    iconbg: ThcColors.green67,
  );

  static const radius = 8.0;

  @override
  Widget build(BuildContext context) {
    final progress = LoginProgressTracker.of(context);
    final LoginProgress(:method, :twoLoginFields, :showBottom, :pressedStart) = progress;

    void Function([dynamic])? buttonPress;
    if (username?.isEmpty ?? false) {
      buttonPress = ([_]) {
        LoginProgressTracker.update(twoLoginFields: true);
      };
    }

    final (:icon, :iconfg, :iconbg) = twoLoginFields ? doneData : continueData;
    final Widget topText = Column(
      children: [
        TextField(
          focusNode: usernameNode,
          decoration: InputDecoration(
            border: InputBorder.none,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelStyle: const TextStyle(color: StartColors.bg),
            hintText: switch (method) {
              _ when !pressedStart => null,
              LoginMethod.idName => 'user ID',
              LoginMethod.noID => 'email address',
              LoginMethod.signIn => 'user ID or email',
            },
          ),
          onChanged: (value) => setState(() => username = value),
          onSubmitted: buttonPress,
        ),
        if (twoLoginFields)
          TextField(
            focusNode: passwordNode,
            decoration: InputDecoration(
              border: InputBorder.none,
              floatingLabelBehavior: FloatingLabelBehavior.never,
              labelStyle: const TextStyle(color: StartColors.bg12),
              hintText: switch (method) {
                LoginMethod.idName => 'first and last name',
                LoginMethod.noID => throw Exception('There should only be 1 field right now.'),
                LoginMethod.signIn => 'password',
              },
            ),
            onChanged: (value) => setState(() => username = value),
            onSubmitted: buttonPress,
          ),
      ],
    );

    final fancyField = Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: LayoutBuilder(
        builder: (context, constraints) => AnimatedContainer(
          duration: Durations.long4,
          curve: Curves.easeOutCubic,
          constraints: BoxConstraints(maxWidth: pressedStart ? constraints.maxWidth : 125),
          decoration: BoxDecoration(
            border: Border.fromBorderSide(
              pressedStart
                  ? BorderSide.none
                  : const BorderSide(color: ThcColors.green, width: 2.5),
            ),
            borderRadius: BorderRadius.all(Radius.circular(pressedStart ? radius : 0x100)),
            color: Colors.white.withAlpha(pressedStart ? 0x70 : 0xa0),
          ),
          padding: EdgeInsets.symmetric(horizontal: pressedStart ? 10 : 0),
          child: Stack(
            children: [
              topText,
              if (!pressedStart)
                Positioned.fill(
                  child: TextButton(
                    onPressed: () async {
                      LoginProgressTracker.update(pressedStart: true);
                      await Future.delayed(ZaHando.transition);
                      LoginProgressTracker.update(showBottom: true);
                      await Future.delayed(ZaHando.shrinkDuration);
                      usernameNode.requestFocus();
                    },
                    child: const Center(
                      child: Text(
                        'start',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: ThcColors.green,
                        ),
                      ),
                    ),
                  ),
                ),
              if (username != null)
                Align(
                  alignment: buttonAlignment,
                  child: SizedBox(
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
                ),
            ],
          ),
        ),
      ),
    );

    return Column(
      children: [
        fancyField,
        if (showBottom) const BottomStuff(),
      ],
    );
  }
}
