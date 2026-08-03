import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'app_theme_extension.dart';

class AppTheme {
  static const SpacingTokens spacing = SpacingTokens();
  static const RadiusTokens radius = RadiusTokens();
  static const TypographyTokens typography = TypographyTokens();
  static const DimensionTokens dimensions = DimensionTokens();

  static final ThemeData light = _buildTheme(
    colors: const LightColorTokens(),
    brightness: Brightness.light,
  );

  static final ThemeData dark = _buildTheme(
    colors: const DarkColorTokens(),
    brightness: Brightness.dark,
  );

  static final ThemeData aurora = _buildTheme(
    colors: const AuroraColorTokens(),
    brightness: Brightness.light,
  );

  static final Map<String, ThemeData> themes = {
    'light': light,
    'dark': dark,
    'aurora': aurora,
  };

  static ThemeData theme(String themeName) => themes[themeName] ?? themes.values.first;

  static ThemeData _buildTheme({
    required ColorTokensBase colors,
    required Brightness brightness,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      colorScheme: brightness == Brightness.dark
          ? ColorScheme.dark(
              primary: colors.primary,
              surface: colors.surface,
              error: colors.error,
            )
          : ColorScheme.light(
              primary: colors.primary,
              surface: colors.surface,
              error: colors.error,
            ),
      extensions: [
        AppThemeExtension(
          colors: colors,
          spacing: spacing,
          radius: radius,
          typography: typography,
          dimensions: dimensions,
        ),
      ],
    );
  }
}
