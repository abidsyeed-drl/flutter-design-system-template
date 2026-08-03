# Flutter Design System Template

Single-command token pipeline for Flutter.

## Phase 1 Goal

Change values in [tokens.json](lib/core/design_system/generator/tokens.json), run one command, and the app theme + token files update.

## Generate Command

```bash
dart run lib/core/design_system/generator/generate_tokens.dart
```

## What The Generator Owns

- Generated token files under [lib/core/design_system/generated](lib/core/design_system/generated)
- Wrapper scaffolding in [lib/core/design_system/tokens](lib/core/design_system/tokens)
- Theme files:
	- [lib/core/design_system/theme/app_theme.dart](lib/core/design_system/theme/app_theme.dart)
	- [lib/core/design_system/theme/app_theme_extension.dart](lib/core/design_system/theme/app_theme_extension.dart)
- Context extension:
	- [lib/core/design_system/extensions/context_extension.dart](lib/core/design_system/extensions/context_extension.dart)
- Responsive helpers:
	- [lib/core/design_system/responsive/responsive.dart](lib/core/design_system/responsive/responsive.dart)
	- [lib/core/design_system/responsive/responsive_value.dart](lib/core/design_system/responsive/responsive_value.dart)
- Token export barrel:
	- [lib/core/design_system/tokens/tokens.dart](lib/core/design_system/tokens/tokens.dart)

## Manual Code Safety

- Existing manual methods in token wrapper classes are preserved.
- Missing wrapper files are auto-created.
- Theme-specific color override getters are now updated when values change in [tokens.json](lib/core/design_system/generator/tokens.json), not just appended once.

## Themes

- Theme keys are read from `themes` in [tokens.json](lib/core/design_system/generator/tokens.json).
- For each key, generator creates:
	- Generated color class (for source of truth)
	- Token wrapper class named from key (`light -> ColorTokens`, `dark -> DarkColorTokens`, `aurora -> AuroraColorTokens`)
	- AppTheme entry in `AppTheme.themes`

## App Wiring

The app currently uses a selectable brand theme with system dark-mode support in [lib/main.dart](lib/main.dart).
