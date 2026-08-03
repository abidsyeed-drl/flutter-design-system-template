import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('lib/core/design_system/generator/tokens.json');
  final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

  generateColors(data);
  generateSpacing(data);
  generateRadius(data);
  generateTypography(data);
  generateDimensions(data);
  updateTokenWrappers(data);
  updateTokensBarrel();
  updateAppThemeExtension(data);
  updateAppTheme(data);
  updateContextExtension();
  ensureResponsiveFiles();

  print('All tokens generated');
}

Map<String, dynamic> _map(dynamic value, String message) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  throw StateError(message);
}

List<MapEntry<String, dynamic>> _orderedEntries(Map<String, dynamic> map) {
  return map.entries.toList(growable: false);
}

String _pascalCase(String value) {
  final parts = value.split(RegExp(r'[^A-Za-z0-9]+')).where((part) => part.isNotEmpty);
  return parts.map((part) => part[0].toUpperCase() + part.substring(1)).join();
}

String _camelCase(String value) {
  final pascal = _pascalCase(value);
  if (pascal.isEmpty) {
    return value;
  }
  return pascal[0].toLowerCase() + pascal.substring(1);
}

String _themeClassName(String themeName) => 'Generated${_pascalCase(themeName)}ColorTokens';

String _themeBaseClassName() => 'GeneratedThemeColorTokens';

String _tokenThemeClassName(String themeName) {
  if (themeName.toLowerCase() == 'light') {
    return 'ColorTokens';
  }
  return '${_pascalCase(themeName)}ColorTokens';
}

// ---------------- COLORS ----------------

void generateColors(Map<String, dynamic> data) {
  final themes = _map(data['themes'], 'Missing "themes" in tokens.json');
  final themeEntries = _orderedEntries(themes);
  if (themeEntries.isEmpty) {
    throw StateError('tokens.json must define at least one theme');
  }

  final allColorKeys = <String>{};
  for (final themeEntry in themeEntries) {
    final theme = _map(themeEntry.value, 'Invalid theme definition for "${themeEntry.key}"');
    final colors =
        _map(theme['colors'], 'Missing "themes.${themeEntry.key}.colors" in tokens.json');
    allColorKeys.addAll(colors.keys.cast<String>());
  }

  final sortedColorKeys = allColorKeys.toList();

  final buffer = StringBuffer();
  buffer.writeln("import 'package:flutter/material.dart';");
  buffer.writeln();
  buffer.writeln('abstract class ${_themeBaseClassName()} {');
  buffer.writeln('  const ${_themeBaseClassName()}();');
  for (final key in sortedColorKeys) {
    buffer.writeln('  Color get $key;');
  }
  buffer.writeln('}');
  buffer.writeln();

  for (final themeEntry in themeEntries) {
    final themeName = themeEntry.key;
    final colors = _map(
      _map(themeEntry.value, 'Invalid theme definition for "$themeName"')['colors'],
      'Missing "themes.$themeName.colors" in tokens.json',
    );
    final className = _themeClassName(themeName);
    buffer.writeln('class $className extends ${_themeBaseClassName()} {');
    buffer.writeln('  const $className();');
    for (final key in sortedColorKeys) {
      final value = colors[key];
      if (value == null) {
        throw StateError('Missing "themes.$themeName.colors.$key" in tokens.json');
      }
      buffer.writeln('  @override');
      buffer.writeln('  Color get $key => const Color(0xff${value.toString().substring(1)});');
    }
    buffer.writeln('}');
    if (themeEntry != themeEntries.last) {
      buffer.writeln();
    }
  }

  writeFile('generated_color_tokens.dart', buffer.toString());
}

// ---------------- SPACING ----------------

void generateSpacing(Map<String, dynamic> data) {
  final spacing = _map(data['spacing'], 'Missing "spacing" in tokens.json');

  final output = '''
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';

class GeneratedSpacingTokens {
  const GeneratedSpacingTokens();

${generateResponsiveDouble(spacing)}
}
''';

  writeFile('generated_spacing_tokens.dart', output);
}

String generateResponsiveDouble(Map<String, dynamic> values) {
  final buffer = StringBuffer();

  for (final entry in values.entries) {
    final key = entry.key;
    final token = _map(entry.value, 'Invalid responsive token for "$key"');
    buffer.writeln('''
  double $key(context) {
    return ResponsiveValue<double>(
      mobile: ${token['mobile']},
      tablet: ${token['tablet']},
      desktop: ${token['desktop']},
    ).resolve(context).r;
  }
''');
  }

  return buffer.toString();
}

// ---------------- RADIUS ----------------

void generateRadius(Map<String, dynamic> data) {
  final radius = _map(data['radius'], 'Missing "radius" in tokens.json');

  final output = '''
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';

class GeneratedRadiusTokens {
  const GeneratedRadiusTokens();

${generateResponsiveDouble(radius)}
}
''';

  writeFile('generated_radius_tokens.dart', output);
}

// ---------------- TYPOGRAPHY ----------------

void generateTypography(Map<String, dynamic> data) {
  final typography = _map(data['typography'], 'Missing "typography" in tokens.json');

  final output = '''
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';
import '../theme/app_theme_extension.dart';

class GeneratedTypographyTokens {
  const GeneratedTypographyTokens();

${generateTextStyles(typography)}
}
''';

  writeFile('generated_typography_tokens.dart', output);
}

String generateTextStyles(Map<String, dynamic> values) {
  final buffer = StringBuffer();

  for (final entry in values.entries) {
    final name = entry.key;
    final token = _map(entry.value, 'Invalid typography token for "$name"');
    final size = _map(token['size'], 'Missing typography size for "$name"');
    final colorName = token['color'] as String?;

    if (colorName == null) {
      throw StateError('Missing typography color for "$name"');
    }

    buffer.writeln('''
  TextStyle $name(context) {
    return TextStyle(
      fontSize: ResponsiveValue<double>(
        mobile: ${size['mobile']},
        tablet: ${size['tablet']},
        desktop: ${size['desktop']},
      ).resolve(context).sp,
      fontWeight: FontWeight.w${token['weight']},
      color: Theme.of(context).extension<AppThemeExtension>()!.colors.$colorName,
    );
  }
''');
  }

  return buffer.toString();
}

// ---------------- DIMENSIONS ----------------

void generateDimensions(Map<String, dynamic> data) {
  final dimensions = _map(data['dimensions'], 'Missing "dimensions" in tokens.json');

  final output = '''
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';

class GeneratedDimensionTokens {
  const GeneratedDimensionTokens();

${generateDimensionsCode(dimensions)}
}
''';

  writeFile('generated_dimension_tokens.dart', output);
}

String generateDimensionsCode(Map<String, dynamic> values) {
  final buffer = StringBuffer();

  for (final entry in values.entries) {
    final name = entry.key;
    final token = _map(entry.value, 'Invalid dimension token for "$name"');
    final type = token['type'] as String?;

    final unit = switch (type) {
      'width' => '.w',
      'height' => '.h',
      _ => '.r',
    };

    buffer.writeln('''
  double $name(context) {
    return ResponsiveValue<double>(
      mobile: ${token['mobile']},
      tablet: ${token['tablet']},
      desktop: ${token['desktop']},
    ).resolve(context)$unit;
  }
''');
  }

  return buffer.toString();
}

// ---------------- WRAPPERS ----------------

void updateTokenWrappers(Map<String, dynamic> data) {
  final themes = _map(data['themes'], 'Missing "themes" in tokens.json');
  final themeEntries = _orderedEntries(themes);
  if (themeEntries.isEmpty) {
    throw StateError('tokens.json must define at least one theme');
  }

  final lightThemeExists = themeEntries.any(
    (entry) => entry.key.toLowerCase() == 'light',
  );
  if (!lightThemeExists) {
    throw StateError('tokens.json must define a "light" theme for ColorTokens');
  }

  final colorExtraClasses = <Map<String, dynamic>>[];
  for (final themeEntry in themeEntries) {
    final themeName = themeEntry.key;
    if (themeName.toLowerCase() == 'light') {
      continue;
    }
    colorExtraClasses.add({
      'className': _tokenThemeClassName(themeName),
      'extends': 'ColorTokens',
      'themeKey': themeName,
    });
  }

  final configs = {
    'color_tokens.dart': {
      'className': 'ColorTokens',
      'extends': _themeClassName('light'),
      'imports': [
        '../generated/generated_color_tokens.dart',
        'package:flutter/material.dart',
      ],
      'extraClasses': colorExtraClasses,
    },
    'spacing_tokens.dart': {
      'className': 'SpacingTokens',
      'extends': 'GeneratedSpacingTokens',
      'imports': ['../generated/generated_spacing_tokens.dart'],
    },
    'radius_tokens.dart': {
      'className': 'RadiusTokens',
      'extends': 'GeneratedRadiusTokens',
      'imports': ['../generated/generated_radius_tokens.dart'],
    },
    'typography_tokens.dart': {
      'className': 'TypographyTokens',
      'extends': 'GeneratedTypographyTokens',
      'imports': ['../generated/generated_typography_tokens.dart'],
    },
    'dimension_tokens.dart': {
      'className': 'DimensionTokens',
      'extends': 'GeneratedDimensionTokens',
      'imports': ['../generated/generated_dimension_tokens.dart'],
    },
  };

  for (final entry in configs.entries) {
    final fileName = entry.key;
    final config = entry.value as Map<String, dynamic>;
    final file = File('lib/core/design_system/tokens/$fileName');
    final imports = (config['imports'] as List).cast<String>();
    final className = config['className'] as String;
    final extendsName = config['extends'] as String;
    final extraClasses =
        (config['extraClasses'] as List?)?.cast<Map<String, dynamic>>() ?? const [];

    String content;

    if (file.existsSync()) {
      content = file.readAsStringSync();
    } else {
      content = '';
    }

    for (final importLine in imports) {
      final importStatement = "import '$importLine';";
      if (!content.contains(importStatement)) {
        content = '$importStatement\n$content';
      }
    }

    content = _ensureClass(content, className, extendsName);

    for (final extraClass in extraClasses) {
      final extraName = extraClass['className'] as String;
      final extraExtends = extraClass['extends'] as String;
      content = _ensureClass(content, extraName, extraExtends);
    }

    if (fileName == 'color_tokens.dart') {
      for (final extraClass in extraClasses) {
        final themeKey = extraClass['themeKey'] as String?;
        final classForTheme = extraClass['className'] as String;
        if (themeKey == null) {
          continue;
        }
        final theme = _map(themes[themeKey], 'Missing "themes.$themeKey" in tokens.json');
        final colors = _map(theme['colors'], 'Missing "themes.$themeKey.colors" in tokens.json');
        content = _ensureColorOverrides(content, classForTheme, colors);
      }
    }

    file.writeAsStringSync(content);
  }
}

String _ensureColorOverrides(
  String content,
  String className,
  Map<String, dynamic> colors,
) {
  final classMatch = RegExp(
    r'class\s+' + className + r'\s+extends\s+\w+\s*\{',
  ).firstMatch(content);

  if (classMatch == null) {
    return content;
  }

  final openBraceIndex = classMatch.end - 1;
  int depth = 0;
  int closeBraceIndex = -1;

  for (int i = openBraceIndex; i < content.length; i++) {
    final char = content[i];
    if (char == '{') {
      depth++;
    } else if (char == '}') {
      depth--;
      if (depth == 0) {
        closeBraceIndex = i;
        break;
      }
    }
  }

  if (closeBraceIndex == -1) {
    return content;
  }

  final classBody = content.substring(openBraceIndex + 1, closeBraceIndex);
  final additions = StringBuffer();

  for (final entry in colors.entries) {
    final key = entry.key;
    if (classBody.contains('Color get $key')) {
      continue;
    }
    final value = entry.value.toString().substring(1);
    additions.writeln('');
    additions.writeln('  @override');
    additions.writeln('  Color get $key => const Color(0xff$value);');
  }

  if (additions.isEmpty) {
    return content;
  }

  return content.substring(0, closeBraceIndex) +
      additions.toString() +
      content.substring(closeBraceIndex);
}

String _ensureClass(String content, String className, String extendsName) {
  final classPattern = RegExp(r'class\s+' + className + r'(?:\s+extends\s+\w+)?');
  final classReplacement = 'class $className extends $extendsName';

  if (classPattern.hasMatch(content)) {
    return content.replaceFirst(classPattern, classReplacement);
  }

  final buffer = StringBuffer(content);
  if (buffer.isNotEmpty && !buffer.toString().endsWith('\n')) {
    buffer.writeln();
  }
  buffer.writeln();
  buffer.writeln('$classReplacement {');
  buffer.writeln('  const $className();');
  buffer.writeln('}');
  return buffer.toString();
}

void updateTokensBarrel() {
  final file = File('lib/core/design_system/tokens/tokens.dart');
  final exports = [
    'color_tokens.dart',
    'dimension_tokens.dart',
    'radius_tokens.dart',
    'spacing_tokens.dart',
    'typography_tokens.dart',
  ];

  String content = file.existsSync() ? file.readAsStringSync() : '';

  for (final exportLine in exports) {
    final statement = "export '$exportLine';";
    if (!content.contains(statement)) {
      if (content.isNotEmpty && !content.endsWith('\n')) {
        content += '\n';
      }
      content = '$statement\n$content';
    }
  }

  file.writeAsStringSync(content);
}

// ---------------- THEME FILES ----------------

void updateAppThemeExtension(Map<String, dynamic> data) {
  final output = '''
import 'package:flutter/material.dart';

import '../tokens/tokens.dart';

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final ColorTokens colors;
  final SpacingTokens spacing;
  final RadiusTokens radius;
  final TypographyTokens typography;
  final DimensionTokens dimensions;

  const AppThemeExtension({
    required this.colors,
    required this.spacing,
    required this.radius,
    required this.typography,
    required this.dimensions,
  });

  @override
  AppThemeExtension copyWith({
    ColorTokens? colors,
    SpacingTokens? spacing,
    RadiusTokens? radius,
    TypographyTokens? typography,
    DimensionTokens? dimensions,
  }) {
    return AppThemeExtension(
      colors: colors ?? this.colors,
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
''';

  writeIfChanged('lib/core/design_system/theme/app_theme_extension.dart', output);
}

void updateAppTheme(Map<String, dynamic> data) {
  final themes = _map(data['themes'], 'Missing "themes" in tokens.json');
  final themeEntries = _orderedEntries(themes);
  if (themeEntries.isEmpty) {
    throw StateError('tokens.json must define at least one theme');
  }

  final themeFields = <String>[];
  final themeMapEntries = <String>[];

  for (final themeEntry in themeEntries) {
    final themeName = themeEntry.key;
    final fieldName = _camelCase(themeName);
    final className = _tokenThemeClassName(themeName);
    final brightness =
        themeName.toLowerCase().contains('dark') ? 'Brightness.dark' : 'Brightness.light';

    themeFields.add('''
  static final ThemeData $fieldName = _buildTheme(
    colors: const $className(),
    brightness: $brightness,
  );
''');

    themeMapEntries.add("    '$themeName': $fieldName,");
  }

  final output = '''
import 'package:flutter/material.dart';

import '../tokens/tokens.dart';
import 'app_theme_extension.dart';

class AppTheme {
  static const SpacingTokens spacing = SpacingTokens();
  static const RadiusTokens radius = RadiusTokens();
  static const TypographyTokens typography = TypographyTokens();
  static const DimensionTokens dimensions = DimensionTokens();

${themeFields.join('\n')}
  static final Map<String, ThemeData> themes = {
${themeMapEntries.join('\n')}
  };

  static ThemeData theme(String themeName) => themes[themeName] ?? themes.values.first;

  static ThemeData _buildTheme({
    required ColorTokens colors,
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
              background: colors.background,
              error: colors.error,
            )
          : ColorScheme.light(
              primary: colors.primary,
              surface: colors.surface,
              background: colors.background,
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
''';

  writeIfChanged('lib/core/design_system/theme/app_theme.dart', output);
}

void updateContextExtension() {
  final output = '''
import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';
import '../tokens/color_tokens.dart';

extension ContextExtension on BuildContext {
  AppThemeExtension get appTheme => Theme.of(this).extension<AppThemeExtension>()!;

  ColorTokens get colors => appTheme.colors;

  SpaceExtension get space => SpaceExtension(this);

  RadiusExtension get radius => RadiusExtension(this);

  TypographyExtension get typo => TypographyExtension(this);

  DimensionExtension get dimensions => DimensionExtension(this);
}

class SpaceExtension {
  final BuildContext context;

  SpaceExtension(this.context);

  double get sm => context.appTheme.spacing.sm(context);

  double get md => context.appTheme.spacing.md(context);

  double get lg => context.appTheme.spacing.lg(context);
}

class RadiusExtension {
  final BuildContext context;

  RadiusExtension(this.context);

  double get md => context.appTheme.radius.md(context);
}

class TypographyExtension {
  final BuildContext context;

  TypographyExtension(this.context);

  TextStyle get title => context.appTheme.typography.title(context);

  TextStyle get body => context.appTheme.typography.body(context);
}

class DimensionExtension {
  final BuildContext context;

  DimensionExtension(this.context);

  double get buttonHeight => context.appTheme.dimensions.buttonHeight(context);

  double get icon => context.appTheme.dimensions.icon(context);

  double get avatar => context.appTheme.dimensions.avatar(context);

  double get imageWidth => context.appTheme.dimensions.imageWidth(context);

  double get imageHeight => context.appTheme.dimensions.imageHeight(context);
}
''';

  writeIfChanged('lib/core/design_system/extensions/context_extension.dart', output);
}

// ---------------- RESPONSIVE ----------------

void ensureResponsiveFiles() {
  writeIfChanged('lib/core/design_system/responsive/responsive.dart', '''
import 'package:flutter/widgets.dart';

class Responsive {
  static bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < 600;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 600 && width < 1200;
  }

  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= 1200;
}
''');

  writeIfChanged('lib/core/design_system/responsive/responsive_value.dart', '''
import 'package:flutter/widgets.dart';

class ResponsiveValue<T> {
  final T mobile;
  final T tablet;
  final T desktop;

  const ResponsiveValue({
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  T resolve(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < 600) return mobile;
    if (width < 1200) return tablet;
    return desktop;
  }
}
''');
}

// ---------------- FILE HELPERS ----------------

void writeIfChanged(String path, String content) {
  final file = File(path);
  file.parent.createSync(recursive: true);

  if (file.existsSync()) {
    final existing = file.readAsStringSync();
    if (existing == content) {
      return;
    }
  }

  file.writeAsStringSync(content);
}

void writeFile(String name, String content) {
  final directory = Directory('lib/core/design_system/generated');

  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  final file = File('${directory.path}/$name');
  file.writeAsStringSync(content);
}
