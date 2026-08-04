import 'package:flutter/material.dart';
import 'package:flutter_design_system_template/core/design_system/extensions/context_extension.dart';
import 'package:flutter_design_system_template/core/design_system/theme/app_theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('context extension exposes usable design tokens', (tester) async {
    late Color primary;
    late Gradient brandGradient;
    late double spaceMd;
    late double radiusMd;
    late TextStyle title;
    late double buttonHeight;
    late List<BoxShadow> cardShadow;
    late double level2;
    late double surfaceElevation;
    late double dialogElevation;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) {
          return MaterialApp(
            theme: AppTheme.light,
            home: Builder(
              builder: (context) {
                primary = context.colors.primary;
                brandGradient = context.gradients.brandLinear;
                spaceMd = context.space.md;
                radiusMd = context.radius.md;
                title = context.typo.title;
                buttonHeight = context.dimensions.buttonHeight;
                cardShadow = context.shadows.card;
                level2 = context.elevation.level2;
                surfaceElevation = context.elevation.surface;
                dialogElevation = context.elevation.dialog;
                return const SizedBox.shrink();
              },
            ),
          );
        },
      ),
    );

    expect(primary.alpha, greaterThanOrEqualTo(0));
    expect(brandGradient, isA<Gradient>());
    expect(spaceMd, greaterThan(0));
    expect(radiusMd, greaterThan(0));
    expect(title.fontSize, isNotNull);
    expect(buttonHeight, greaterThan(0));
    expect(cardShadow, isNotEmpty);
    expect(level2, greaterThan(0));
    expect(surfaceElevation, greaterThan(0));
    expect(dialogElevation, greaterThan(surfaceElevation));
  });

  testWidgets('home screen renders with design-system themed app', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, __) {
          return MaterialApp(
            theme: AppTheme.aurora,
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Text(
                    'smoke',
                    style: context.typo.body,
                  );
                },
              ),
            ),
          );
        },
      ),
    );

    expect(find.text('smoke'), findsOneWidget);
  });
}
