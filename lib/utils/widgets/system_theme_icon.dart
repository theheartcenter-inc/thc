import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class SystemThemeIcon extends StatelessWidget {
  const SystemThemeIcon({required this.color, this.size = 25.0, super.key});
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
