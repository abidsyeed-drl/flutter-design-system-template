import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../responsive/responsive_value.dart';
import '../theme/app_theme_extension.dart';

class GeneratedTypographyTokens {
  const GeneratedTypographyTokens();

  TextStyle title(context) {
    return TextStyle(
      fontSize: ResponsiveValue<double>(
        mobile: 24,
        tablet: 28,
        desktop: 36,
      ).resolve(context).sp,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).extension<AppThemeExtension>()!.colors.textPrimary,
    );
  }

  TextStyle body(context) {
    return TextStyle(
      fontSize: ResponsiveValue<double>(
        mobile: 14,
        tablet: 16,
        desktop: 18,
      ).resolve(context).sp,
      fontWeight: FontWeight.w400,
      color: Theme.of(context).extension<AppThemeExtension>()!.colors.textSecondary,
    );
  }


}
