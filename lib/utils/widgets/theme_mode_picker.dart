import 'package:flutter_svg/svg.dart';
import 'package:thc/start/start.dart';
import 'package:thc/the_good_stuff.dart';

/// {@template ThemeModePicker}
/// An animated button shown in the [StartScreen] used to set the [ThemeMode].
/// {@endtemplate}
class ThemeModePicker extends HookWidget {
  /// {@macro ThemeModePicker}
  const ThemeModePicker({this.backgroundColor, this.foregroundColor, super.key});
  final Color? backgroundColor, foregroundColor;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: Durations.short3);
    final t = useAnimation(controller);

    Future<void> toggle([ThemeMode? mode]) async {
      if (controller.isForwardOrCompleted && mode != null) {
        context.read<AppTheme>().value = mode;
        LocalStorage.themeMode.save(mode.index);
      }
      controller.toggle();
    }

    final themeMode = context.watch<AppTheme>().value;

    const curve = Curves.ease;
    final bool forwardOrComplete = controller.isForwardOrCompleted;
    final tCurve = forwardOrComplete ? curve.transform(t) : 1 - curve.transform(1 - t);

    final Color foreground = foregroundColor ?? IconTheme.of(context).color ?? Colors.white;
    final double fgOpacity = foreground.opacity;
    final Color splashColor = foreground.withOpacity(fgOpacity / 4);

    final double width = 72 * tCurve;
    final double height = 80 * tCurve;

    Widget? themeButton(ThemeMode buttonMode) {
      final active = buttonMode == themeMode;
      if (t == 0 && !active) return null;

      final iconfg = foreground.withOpacity(fgOpacity * (active ? 1 : tCurve));

      return Positioned.fill(
        key: ValueKey(buttonMode),
        top: tCurve * buttonMode.index * (height + 48) / 3,
        bottom: tCurve * (2 - buttonMode.index) * (height + 48) / 3,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: ValueKey(buttonMode),
            onTap: t.remainder(1) == 0 ? () => toggle(buttonMode) : null,
            overlayColor: WidgetStateProperty.resolveWith(
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
                      style: TextStyle(weight: 600, color: foreground),
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

    return TapRegion(
      onTapOutside: (_) => controller.isForwardOrCompleted ? toggle() : null,
      child: SizedBox(
        width: width + 48,
        height: height + 48,
        child: ClipRRect(
          borderRadius: BorderRadius.circular((1 - tCurve) * 16 + 8),
          child: ColoredBox(
            color: backgroundColor ?? Theme.of(context).canvasColor,
            child: Stack(
              children: [
                for (final mode in stacked)
                  if (themeButton(mode) case final button?) button,
              ],
            ),
          ),
        ),
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
