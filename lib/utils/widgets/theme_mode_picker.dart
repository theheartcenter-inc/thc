import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:thc/start/start.dart';
import 'package:thc/utils/animation.dart';
import 'package:thc/utils/local_storage.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';

/// {@template ThemeModePicker}
/// An animated button shown in the [StartScreen] used to set the [ThemeMode].
/// {@endtemplate}
class ThemeModePicker extends StatefulWidget {
  /// {@macro ThemeModePicker}
  const ThemeModePicker({this.backgroundColor, this.foregroundColor, super.key});
  final Color? backgroundColor, foregroundColor;

  @override
  State<ThemeModePicker> createState() => _ThemeModePickerState();
}

class _ThemeModePickerState extends State<ThemeModePicker> with SingleTickerProviderStateMixin {
  late final controller = AnimationController(vsync: this, duration: Durations.short3);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> toggle([ThemeMode? mode]) async {
    final reversing = controller.aimedForward;
    if (reversing && mode != null) {
      context.read<AppTheme>().value = mode;
      LocalStorage.themeMode.save(mode.index);
    }
    return reversing ? controller.reverse(from: 1) : controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) => controller.aimedForward ? toggle() : null,
      child: AnimatedBuilder(animation: controller, builder: builder),
    );
  }

  Widget builder(BuildContext context, _) {
    final themeMode = context.watch<AppTheme>().value;

    final t = controller.value;
    final aimedForward = controller.aimedForward;
    const curve = Curves.ease;
    final tCurve = aimedForward ? curve.transform(t) : 1 - curve.transform(1 - t);

    final foregroundColor = widget.foregroundColor ?? IconTheme.of(context).color ?? Colors.white;
    final fgOpacity = foregroundColor.opacity;
    final splashColor = foregroundColor.withOpacity(fgOpacity / 4);

    final normalRadius = Radius.circular((1 - tCurve) * 24);
    final cornerRadius = Radius.circular((1 - tCurve) * 16 + 8);

    final width = 72 * tCurve;
    final height = 80 * tCurve;

    Widget? button(ThemeMode buttonMode) {
      final active = buttonMode == themeMode;
      if (t == 0 && !active) return null;

      final iconfg = foregroundColor.withOpacity(fgOpacity * (active ? 1 : tCurve));

      return Positioned.fill(
        key: ValueKey(buttonMode),
        top: tCurve * buttonMode.index * (height + 48) / 3,
        bottom: tCurve * (2 - buttonMode.index) * (height + 48) / 3,
        child: Material(
          animationDuration: Duration.zero,
          borderRadius: switch (buttonMode) {
            ThemeMode.light => BorderRadius.all(normalRadius),
            ThemeMode.dark => BorderRadius.vertical(top: normalRadius, bottom: cornerRadius),
            ThemeMode.system => BorderRadius.vertical(top: cornerRadius, bottom: normalRadius),
          },
          color: widget.backgroundColor,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            key: ValueKey(buttonMode),
            onTap: t.remainder(1) == 0 ? () => toggle(buttonMode) : null,
            overlayColor: MaterialStateProperty.resolveWith(
              (states) => states.isPressed && t < 1 ? Colors.transparent : splashColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                switch (buttonMode) {
                  ThemeMode.system => SystemThemeIcon(color: iconfg),
                  ThemeMode.light => Icon(Icons.light_mode, color: iconfg),
                  ThemeMode.dark => Icon(Icons.dark_mode, color: iconfg),
                },
                SizedBox(
                  width: width,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      buttonMode.name,
                      softWrap: false,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.fade,
                      style: StyleText(weight: 600, color: foregroundColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final stacked = [...ThemeMode.values.where((value) => value != themeMode), themeMode];

    return SizedBox(
      width: width + 48,
      height: height + 48,
      child: Stack(
        children: [
          for (final mode in stacked)
            if (button(mode) case final button?) button,
        ],
      ),
    );
  }
}

/// The ["routine" icon](https://fonts.google.com/icons?selected=Material%20Symbols%20Outlined%3Aroutine%3AFILL%401%3Bwght%40400%3BGRAD%400%3Bopsz%4024)
/// isn't part of Flutter's [Icons] collection yet, so we gotta use an svg for now.
class SystemThemeIcon extends StatelessWidget {
  const SystemThemeIcon({required this.color, this.size = 24.0, super.key});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      width: size,
      height: size,
      'assets/svg_files/system_brightness.svg',
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
