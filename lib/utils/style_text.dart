import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

/// We're storing fonts in the `assets/` folder
/// to keep the app appearance consistent across devices.
///
/// Both "pretendard" and "roboto mono" are open-source fonts with variable weight.
class StyleText extends TextStyle {
  /// "Pretendard" is almost exactly like the default Apple fonts,
  /// but it's open-source and free to use!
  const StyleText({
    double? size,
    this.weight,
    super.inherit,
    super.color,
    super.backgroundColor,
    super.letterSpacing,
    super.wordSpacing,
    super.textBaseline,
    super.height,
    super.leadingDistribution,
    super.locale,
    super.foreground,
    super.background,
    super.shadows,
    super.decoration,
    super.decorationColor,
    super.decorationStyle,
    super.decorationThickness,
    super.overflow,
  })  : assert(weight == null || weight is FontWeight || weight is num),
        super(fontSize: size, fontFamily: 'pretendard');

  /// "Roboto mono" is a monospace font,
  /// i.e. a font you'd see with typewriters and code editors.
  const StyleText.mono({
    double? size,
    this.weight,
    super.fontStyle,
    super.inherit,
    super.color,
    super.backgroundColor,
    super.letterSpacing,
    super.wordSpacing,
    super.textBaseline,
    super.height,
    super.leadingDistribution,
    super.locale,
    super.foreground,
    super.background,
    super.shadows,
    super.decoration,
    super.decorationColor,
    super.decorationStyle,
    super.decorationThickness,
    super.overflow,
  })  : assert(weight == null || weight is FontWeight || weight is num),
        super(fontSize: size, fontFamily: 'roboto mono');

  /// The type should either be [FontWeight] or [double].
  ///
  /// In [StyleText.mono], the value can range from 100 to 700;
  /// otherwise, it can go from 50 to 1000.
  final dynamic weight;

  @override
  List<FontVariation>? get fontVariations {
    if (weight == null) return null;

    final w = switch (weight) {
      final FontWeight w => w.value,
      final n => n as num,
    };

    return [FontVariation.weight(w.toDouble())];
  }
}
