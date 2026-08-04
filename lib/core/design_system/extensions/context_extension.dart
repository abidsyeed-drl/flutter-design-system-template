import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';
import '../tokens/color_tokens.dart';

extension ContextExtension on BuildContext {
  AppThemeExtension get appTheme => Theme.of(this).extension<AppThemeExtension>()!;

  ColorTokensBase get colors => appTheme.colors;

  GradientExtension get gradients => GradientExtension(this);

  SpaceExtension get space => SpaceExtension(this);

  RadiusExtension get radius => RadiusExtension(this);

  TypographyExtension get typo => TypographyExtension(this);

  DimensionExtension get dimensions => DimensionExtension(this);
}

class GradientExtension {
  final BuildContext context;

  GradientExtension(this.context);

  Gradient get brandLinear => context.appTheme.gradients.brandLinear(context);

  Gradient get surfaceRadial => context.appTheme.gradients.surfaceRadial(context);

  Gradient get statusSweep => context.appTheme.gradients.statusSweep(context);

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
