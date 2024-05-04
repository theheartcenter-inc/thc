/// {@template autofill}
/// During development, it's nice to have an option to autofill the user ID/password
/// rather than needing to type it in each time.
/// {@endtemplate}
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/start/src/login_fields.dart';
import 'package:thc/start/src/login_progress.dart';
import 'package:thc/start/src/start_theme.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/widgets/lerpy_hero.dart';

/// {@macro autofill}
class AutofillMenu extends StatelessWidget {
  /// {@macro autofill}
  const AutofillMenu() : super(key: Nav.lerpy);

  static const width = 300.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        child: StartTheme(
          child: Builder(builder: _builder),
        ),
      ),
    );
  }

  Widget _builder(BuildContext context) {
    final colors = ThcColors.of(context);
    final bool isLight = colors.brightness == Brightness.light;
    final buttons = [
      for (final userType in UserType.values)
        FilledButton(
          onPressed: () {
            navigator.pop();
            final id = userType.testId;
            LoginProgressTracker.update(fieldValues: (id, id));
            for (final field in LoginField.values) {
              field.controller.text = id;
            }
          },
          style: FilledButton.styleFrom(
            shape: const StadiumBorder(),
            backgroundColor: ThcColors.startBg,
            foregroundColor: colors.surface,
            padding: EdgeInsets.zero,
            visualDensity: const VisualDensity(vertical: 1),
          ),
          child: SizedBox(
            width: 150,
            child: Text(
              '$userType',
              textAlign: TextAlign.center,
              style: StyleText.mono(
                weight: isLight ? 500 : 700,
                color: isLight ? null : Colors.black,
              ),
            ),
          ),
        ),
    ];

    final title = _AutofillIcon(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(children: buttons),
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned.fill(child: _AutofillBackground()),
          title,
        ],
      ),
    );
  }
}

/// {@macro autofill}
class AutofillButton extends StatelessWidget {
  /// {@macro autofill}
  const AutofillButton(this.iconbg, this.iconfg, this.node, {super.key});
  final Color iconbg, iconfg;
  final FocusNode node;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: Theme(
        data: context.editScheme(surface: iconbg, onSurface: iconfg),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox.square(
              dimension: 33,
              child: _AutofillBackground(),
            ),
            IconButton(
              focusNode: node,
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: ThcColors.of(context).onSurface,
              ),
              onPressed: () {
                navigator.showDialog(const AutofillMenu());
              },
              icon: const _AutofillIcon(),
            )
          ],
        ),
      ),
    );
  }
}

abstract class _SmoothColor extends LerpyHero<Color> {
  const _SmoothColor({required super.tag, super.child});

  @override
  Color lerp(Color a, Color b, double t, HeroFlightDirection direction) => Color.lerp(a, b, t)!;
}

class _AutofillBackground extends _SmoothColor {
  const _AutofillBackground() : super(tag: 'autofill background');

  @override
  Color fromContext(BuildContext context) {
    return context.lightDark(ThcColors.lightContainer, Colors.black);
  }

  @override
  Widget builder(BuildContext context, Color value, Widget? child) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: value,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
    );
  }
}

class _AutofillIcon extends _SmoothColor {
  const _AutofillIcon({super.child}) : super(tag: 'autofill icon');

  @override
  Color fromContext(BuildContext context) => ThcColors.of(context).outline;

  @override
  Widget builder(BuildContext context, Color value, Widget? child) {
    final icon = Icon(Icons.build, color: value, size: 20);
    if (child == null) return icon;
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyMedium!,
      softWrap: false,
      overflow: TextOverflow.fade,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 24),
              SizedBox(
                width: min(110, constraints.maxWidth),
                child: Row(
                  children: [
                    icon,
                    const Spacer(),
                    Expanded(
                      flex: 20,
                      child: Text(
                        'Autofill',
                        style: StyleText(
                          size: 24,
                          weight: 550,
                          color: ThcColors.of(context).outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: constraints.maxWidth,
                child: FittedBox(
                  child: SizedBox(width: AutofillMenu.width - 50, child: child),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
