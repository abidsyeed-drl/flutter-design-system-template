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
  updateTokenFiles();
  updateTokensBarrel();

  print('All tokens generated');
}

Map<String, dynamic> _map(dynamic value, String message) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  throw StateError(message);
}

// ---------------- COLORS ----------------

void generateColors(Map<String, dynamic> data) {
  final themes = _map(data['themes'], 'Missing "themes" in tokens.json');
  final lightTheme = _map(themes['light'], 'Missing "themes.light" in tokens.json');
  final darkTheme = _map(themes['dark'], 'Missing "themes.dark" in tokens.json');
  final light = _map(lightTheme['colors'], 'Missing "themes.light.colors" in tokens.json');
  final dark = _map(darkTheme['colors'], 'Missing "themes.dark.colors" in tokens.json');

  final output = '''
import 'package:flutter/material.dart';

${generateColorClass('GeneratedLightColorTokens', light)}

${generateColorClass('GeneratedDarkColorTokens', dark)}
''';

  writeFile('generated_color_tokens.dart', output);
}

String generateColorClass(String name, Map<String, dynamic> values) {
  final buffer = StringBuffer();

  buffer.writeln('class $name {');
  buffer.writeln('  const $name();');

  values.forEach((key, value) {
    buffer.writeln('  Color get $key => const Color(0xff${value.toString().substring(1)});');
  });

  buffer.writeln('}');
  return buffer.toString();
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

  values.forEach((key, value) {
    final token = _map(value, 'Invalid responsive token for "$key"');
    buffer.writeln('''
  double $key(context) {
    return ResponsiveValue<double>(
      mobile: ${token['mobile']},
      tablet: ${token['tablet']},
      desktop: ${token['desktop']},
    ).resolve(context).r;
  }
''');
  });

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

  values.forEach((name, value) {
    final token = _map(value, 'Invalid typography token for "$name"');
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
  });

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

  values.forEach((name, value) {
    final token = _map(value, 'Invalid dimension token for "$name"');
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
  });

  return buffer.toString();
}

void updateTokenFiles() {
  final configs = {
    'color_tokens.dart': {
      'className': 'ColorTokens',
      'extends': 'GeneratedLightColorTokens',
      'imports': ['../generated/generated_color_tokens.dart'],
      'dark': true,
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

  configs.forEach((fileName, config) {
    final file = File('lib/core/design_system/tokens/$fileName');
    final imports = (config['imports'] as List).cast<String>();
    final className = config['className'] as String;
    final extendsName = config['extends'] as String;

    String content;

    if (file.existsSync()) {
      content = file.readAsStringSync();
    } else {
      content = 'class $className {\n  const $className();\n}\n';
      if (config['dark'] == true) {
        content += '\nclass DarkColorTokens {\n  const DarkColorTokens();\n}\n';
      }
    }

    for (final importLine in imports) {
      final importStatement = "import '$importLine';";
      if (!content.contains(importStatement)) {
        content = '$importStatement\n$content';
      }
    }

    final classPattern = RegExp(r'class\s+' + className + r'(?:\s+extends\s+\w+)?');
    final classReplacement = 'class $className extends $extendsName';

    if (classPattern.hasMatch(content)) {
      content = content.replaceFirst(classPattern, classReplacement);
    } else {
      if (!content.endsWith('\n')) {
        content += '\n';
      }
      content += '\n$classReplacement {\n  const $className();\n}\n';
    }

    if (config['dark'] == true && !content.contains('class DarkColorTokens')) {
      if (!content.endsWith('\n')) {
        content += '\n';
      }
      content +=
          '\nclass DarkColorTokens extends GeneratedDarkColorTokens {\n  const DarkColorTokens();\n}\n';
    }

    file.writeAsStringSync(content);
  });
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

  String content;

  if (file.existsSync()) {
    content = file.readAsStringSync();
  } else {
    content = '';
  }

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

void writeFile(String name, String content) {
  final directory = Directory('lib/core/design_system/generated');

  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }

  final file = File('${directory.path}/$name');
  file.writeAsStringSync(content);
}
