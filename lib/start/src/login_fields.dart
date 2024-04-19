import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thc/start/src/bottom_stuff.dart';
import 'package:thc/start/src/progress_tracker.dart';
import 'package:thc/start/src/start_theme.dart';
import 'package:thc/start/src/za_hando.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/enum_widget.dart';

enum LoginField with StatelessEnum {
  top,
  bottom;

  FocusNode get node => switch (this) { top => nodes.$1, bottom => nodes.$2 };
  static final nodes = (FocusNode(), FocusNode());
  Future<void> listener() async {
    if (node.hasFocus) {
      LoginProgressTracker.update(focusedField: this);
      return;
    }
    await Future.delayed(const Duration(milliseconds: 50));
    LoginProgressTracker.unfocus(this);
  }

  void Function([dynamic])? submit(String? thisVal) {
    if (thisVal?.isEmpty ?? true) return null;
    return ([_]) => LoginProgressTracker.submit(this);
  }

  @override
  Widget build(BuildContext context) {
    final LoginProgress(
      :method,
      :focusedField,
      :animation,
      :fieldValues,
    ) = LoginProgressTracker.of(context);

    final showBottom = animation >= AnimationProgress.showBottom;
    final (thisVal, otherVal) = switch (this) {
      top => fieldValues,
      bottom => (fieldValues.$2, fieldValues.$1),
    };

    return TextField(
      focusNode: node,
      decoration: InputDecoration(
        border: InputBorder.none,
        hoverColor: Colors.transparent,
        fillColor: Colors.white.withOpacity(focusedField == this ? 0.5 : 0),
        filled: true,
        hintText: switch ((this, method)) {
          _ when !(showBottom || focusedField == LoginField.top) => null,
          (top, LoginMethod.idName) => 'user ID',
          (top, LoginMethod.noID) => 'email address',
          (top, LoginMethod.signIn) => 'user ID or email',
          (bottom, LoginMethod.idName) => 'First and Last name',
          (bottom, LoginMethod.noID) => throw StateError('there should only be 1 email field'),
          (bottom, LoginMethod.signIn) => 'password',
        },
      ),
      onChanged: (value) => LoginProgressTracker.update(
          fieldValues: switch (this) {
        top => (value, otherVal),
        bottom => (otherVal, value),
      }),
      onSubmitted: submit(thisVal),
    );
  }
}

class LoginFields extends StatelessWidget {
  const LoginFields({super.key});

  static final continueData = (
    icon: switch (defaultTargetPlatform) {
      TargetPlatform.iOS => Icons.arrow_forward_ios,
      _ => Icons.arrow_forward,
    },
    iconbg: StartColors.bg38,
  );
  static const doneData = (
    icon: Icons.done,
    iconbg: ThcColors.green67,
  );

  @override
  Widget build(BuildContext context) {
    final LoginProgress(
      :animation,
      :twoLoginFields,
      :fieldValues,
    ) = LoginProgressTracker.of(context);

    final expandText = animation >= AnimationProgress.collapseHand;
    final showBottom = animation >= AnimationProgress.showBottom;
    final (username, password) = fieldValues;

    late final startButton = TextButton(
      onPressed: animate,
      child: AnimatedOpacity(
        duration: Durations.extralong4,
        opacity: expandText ? 0 : 1,
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
    );

    final (:icon, :iconbg) = twoLoginFields ? doneData : continueData;
    final onPressed =
        twoLoginFields ? LoginField.bottom.submit(password) : LoginField.top.submit(username);
    final continueButton = Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 33,
          height: 33,
          child: ClipOval(
            child: AnimatedOpacity(
              opacity: onPressed == null ? 0.5 : 1,
              duration: Durations.short1,
              child: ColoredBox(color: iconbg),
            ),
          ),
        ),
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: Colors.white),
        )
      ],
    );

    final fancyField = Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 10),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          AnimatedContainer(
            duration: Durations.extralong4,
            curve: Curves.easeInOutQuart,
            width: expandText ? 400 : 125,
            decoration: BoxDecoration(
              border: Border.fromBorderSide(
                expandText
                    ? BorderSide.none
                    : const BorderSide(color: ThcColors.green, width: 2.5),
              ),
              borderRadius: BorderRadius.all(Radius.circular(expandText ? 8 : 0x100)),
              color: Colors.white.withAlpha(expandText ? 0x40 : 0xa0),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                LoginField.top,
                if (twoLoginFields) LoginField.bottom,
              ],
            ),
          ),
          Positioned.fill(child: showBottom ? const SizedBox.shrink() : startButton),
          if (username != null) continueButton,
        ],
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
