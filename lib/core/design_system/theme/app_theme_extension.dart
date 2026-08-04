import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final ColorTokensBase colors;
  final GradientTokensBase gradients;
  final SpacingTokens spacing;
  final RadiusTokens radius;
  final TypographyTokens typography;
  final DimensionTokens dimensions;

  const AppThemeExtension({
    required this.colors,
    required this.gradients,
    required this.spacing,
    required this.radius,
    required this.typography,
    required this.dimensions,
  });

  @override
  AppThemeExtension copyWith({
    ColorTokensBase? colors,
    GradientTokensBase? gradients,
    SpacingTokens? spacing,
    RadiusTokens? radius,
    TypographyTokens? typography,
    DimensionTokens? dimensions,
  }) {
    return AppThemeExtension(
      colors: colors ?? this.colors,
      gradients: gradients ?? this.gradients,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
      typography: typography ?? this.typography,
      dimensions: dimensions ?? this.dimensions,
    );
  }

  @override
  AppThemeExtension lerp(
    covariant ThemeExtension<AppThemeExtension>? other,
    double t,
  ) {
    if (other is! AppThemeExtension) {
      return this;
    }

    return t < 0.5 ? this : other;
  }
}
