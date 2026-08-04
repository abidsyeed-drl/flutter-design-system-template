import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('color wrapper file keeps expected inheritance contract', () {
    final file = File('lib/core/design_system/tokens/color_tokens.dart');
    final content = file.readAsStringSync();

    expect(
      content,
      contains(
          'class LightColorTokens extends GeneratedLightColorTokens implements ColorTokensBase'),
    );
    expect(
      content,
      contains('class DarkColorTokens extends GeneratedDarkColorTokens implements ColorTokensBase'),
    );
    expect(
      content,
      contains(
          'class AuroraColorTokens extends GeneratedAuroraColorTokens implements ColorTokensBase'),
    );

    // Legacy name should not come back after regeneration.
    expect(content.contains('class ColorTokens extends GeneratedLightColorTokens'), isFalse);
  });

  test('generated colors file contains base class and one class per theme', () {
    final file = File('lib/core/design_system/generated/generated_color_tokens.dart');
    final content = file.readAsStringSync();

    expect(content, contains('abstract class GeneratedThemeColorTokens'));
    expect(content, contains('class GeneratedLightColorTokens extends GeneratedThemeColorTokens'));
    expect(content, contains('class GeneratedDarkColorTokens extends GeneratedThemeColorTokens'));
    expect(content, contains('class GeneratedAuroraColorTokens extends GeneratedThemeColorTokens'));
  });

  test('gradient wrapper file keeps expected inheritance contract', () {
    final file = File('lib/core/design_system/tokens/gradient_tokens.dart');
    final content = file.readAsStringSync();

    expect(
      content,
      contains(
          'class LightGradientTokens extends GeneratedLightGradientTokens implements GradientTokensBase'),
    );
    expect(
      content,
      contains(
          'class DarkGradientTokens extends GeneratedDarkGradientTokens implements GradientTokensBase'),
    );
    expect(
      content,
      contains(
          'class AuroraGradientTokens extends GeneratedAuroraGradientTokens implements GradientTokensBase'),
    );
  });

  test('generated gradients file contains base class and one class per theme', () {
    final file = File('lib/core/design_system/generated/generated_gradient_tokens.dart');
    final content = file.readAsStringSync();

    expect(content, contains('abstract class GeneratedThemeGradientTokens'));
    expect(
      content,
      contains('class GeneratedLightGradientTokens extends GeneratedThemeGradientTokens'),
    );
    expect(
      content,
      contains('class GeneratedDarkGradientTokens extends GeneratedThemeGradientTokens'),
    );
    expect(
      content,
      contains('class GeneratedAuroraGradientTokens extends GeneratedThemeGradientTokens'),
    );
  });

  test('shadow wrapper file keeps expected inheritance contract', () {
    final file = File('lib/core/design_system/tokens/shadow_tokens.dart');
    final content = file.readAsStringSync();

    expect(
      content,
      contains(
          'class LightShadowTokens extends GeneratedLightShadowTokens implements ShadowTokensBase'),
    );
    expect(
      content,
      contains(
          'class DarkShadowTokens extends GeneratedDarkShadowTokens implements ShadowTokensBase'),
    );
    expect(
      content,
      contains(
          'class AuroraShadowTokens extends GeneratedAuroraShadowTokens implements ShadowTokensBase'),
    );
  });

  test('generated shadows file contains base class and one class per theme', () {
    final file = File('lib/core/design_system/generated/generated_shadow_tokens.dart');
    final content = file.readAsStringSync();

    expect(content, contains('abstract class GeneratedThemeShadowTokens'));
    expect(
      content,
      contains('class GeneratedLightShadowTokens extends GeneratedThemeShadowTokens'),
    );
    expect(
      content,
      contains('class GeneratedDarkShadowTokens extends GeneratedThemeShadowTokens'),
    );
    expect(
      content,
      contains('class GeneratedAuroraShadowTokens extends GeneratedThemeShadowTokens'),
    );
  });

  test('elevation wrapper file keeps expected inheritance contract', () {
    final file = File('lib/core/design_system/tokens/elevation_tokens.dart');
    final content = file.readAsStringSync();

    expect(content, contains('class ElevationTokens extends GeneratedElevationTokens'));
  });

  test('generated elevations file contains generated elevation class', () {
    final file = File('lib/core/design_system/generated/generated_elevation_tokens.dart');
    final content = file.readAsStringSync();

    expect(content, contains('class GeneratedElevationTokens'));
    expect(content, contains('double level1(context)'));
    expect(content, contains('double level2(context)'));
    expect(content, contains('double level3(context)'));
  });
}
