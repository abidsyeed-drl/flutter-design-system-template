# Flutter Design System Template

Single-command token pipeline for Flutter.

## Phase 1 Goal

Change values in [tokens.json](lib/core/design_system/generator/tokens.json), run one command, and the app theme + token files update.

## Generate Command

```bash
dart run lib/core/design_system/generator/generate_tokens.dart
```

The generator now validates token schema before writing files. Invalid tokens fail fast with a clear `StateError`.

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
	- Token wrapper class named from key (`light -> LightColorTokens`, `dark -> DarkColorTokens`, `aurora -> AuroraColorTokens`)
	- AppTheme entry in `AppTheme.themes`

## App Wiring

The app currently uses a selectable brand theme with system dark-mode support in [lib/main.dart](lib/main.dart).

## Current Status

- Phase 1 workflow is complete for local development: edit [tokens.json](lib/core/design_system/generator/tokens.json), run the generate command, and consume tokens in app UI.
- Project is intentionally app-first right now (not packaged yet).
- Next phase focuses on reliability and automation (schema validation, tests, and Figma export integration).

## Schema Validation Rules

- Required sections: `themes`, `spacing`, `radius`, `typography`, `dimensions`
- `themes` must include `light`
- Theme color values must be in `#RRGGBB` format
- Every theme must use the same color keys as `light`
- Responsive values (`mobile`, `tablet`, `desktop`) must be numeric
- `dimensions.*.type` must be one of: `width`, `height`, `radius`
- Typography color references must exist in `themes.light.colors`

## Test Commands

Run schema regression tests:

```bash
flutter test test/generator/schema_validation_test.dart
```

Run idempotency regression test:

```bash
flutter test test/generator/idempotency_test.dart
```

Run missing-file recovery regression test:

```bash
flutter test test/generator/missing_file_recovery_test.dart
```

Run theme-map sync and wrapper contract tests:

```bash
flutter test test/generator/theme_map_sync_test.dart
flutter test test/generator/token_wrapper_contract_test.dart
```

Run runtime design-system smoke tests:

```bash
flutter test test/design_system/runtime_smoke_test.dart
```

Run full generator reliability suite:

```bash
flutter test test/generator
```

Run all tests:

```bash
flutter test
```

Fixture files for invalid token inputs live under [test/fixtures](test/fixtures).
