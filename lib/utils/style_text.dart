import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

class StyleText extends TextStyle {
  const StyleText({
    double? size,
    bool extraBold = false,
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
    super.debugLabel,
    super.package,
    super.overflow,
  })  : assert(weight == null || weight is FontWeight || weight is num),
        super(
          fontSize: size,
          fontFamily: 'pretendard',
          fontWeight: extraBold ? FontWeight.bold : FontWeight.normal,
        );

  const StyleText.mono({
    double? size,
    bool italic = false,
    bool extraBold = false,
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
    super.debugLabel,
    super.package,
    super.overflow,
  })  : assert(weight == null || weight is FontWeight || weight is num),
        super(
          fontSize: size,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          fontFamily: 'roboto mono',
          fontWeight: extraBold ? FontWeight.bold : FontWeight.normal,
        );

  /// The type should either be [FontWeight] or [double].
  ///
  /// In [Style.mono], the value can range from 100 to 700;
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
