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
- Optional per-theme `gradients` are supported
- If gradients are present in `light`, all themes must define gradients with identical keys
- Gradient types supported: `linear`, `radial`, `sweep`

## Gradient Token Schema

Put gradients inside each theme, next to `colors`:

```json
{
	"themes": {
		"light": {
			"colors": { "primary": "#2563EB" },
			"gradients": {
				"brandLinear": {
					"type": "linear",
					"begin": "topLeft",
					"end": "bottomRight",
					"colors": ["primary", "secondary"]
				},
				"surfaceRadial": {
					"type": "radial",
					"center": "center",
					"radius": 1.15,
					"colors": ["#FFFFFF", "#DBEAFE"]
				},
				"statusSweep": {
					"type": "sweep",
					"center": "center",
					"startAngle": 0.0,
					"endAngle": 6.28318,
					"colors": ["#16A34A", "#F59E0B", "#DC2626", "#16A34A"]
				}
			}
		}
	}
}
```

Preferred approach: use color-key references in gradient `colors` (for example `primary`, `secondary`, `error`) so gradients stay synchronized with theme colors.

Fallback approach: direct hex colors are still supported (`#RRGGBB`) when needed.

Generated outputs include:

- [lib/core/design_system/generated/generated_gradient_tokens.dart](lib/core/design_system/generated/generated_gradient_tokens.dart)
- [lib/core/design_system/tokens/gradient_tokens.dart](lib/core/design_system/tokens/gradient_tokens.dart)
- `context.gradients` access via [lib/core/design_system/extensions/context_extension.dart](lib/core/design_system/extensions/context_extension.dart)

## Test Commands

Run schema regression tests:

```bash
flutter test test/generator/schema_validation_test.dart
```

This includes invalid gradient-schema fixtures as well.

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

## Figma To Flutter Guide (Beginner)

If you are starting from zero, follow this order.

### Step 1: Create a test Figma file

Create a new Figma file and add Variables for:

- Colors: primary, surface, background, textPrimary, textSecondary, error
- Spacing: sm, md, lg
- Radius: md
- Typography: title, body
- Dimensions: buttonHeight, icon, avatar, imageWidth, imageHeight
- Gradients: brandLinear (linear), surfaceRadial (radial), statusSweep (sweep)

Keep the naming exactly aligned with [lib/core/design_system/generator/tokens.json](lib/core/design_system/generator/tokens.json).

### Step 2: Export JSON first (manual MVP)

Use a Figma tokens plugin to export variable values to JSON, then map that export into the schema used by [lib/core/design_system/generator/tokens.json](lib/core/design_system/generator/tokens.json).

For the first version, manual copy/paste is fine:

1. Export from Figma plugin.
2. Paste/update [lib/core/design_system/generator/tokens.json](lib/core/design_system/generator/tokens.json).
3. Run generator command.
4. Run tests.

For gradients in Figma Variables/plugin output, map to supported gradient types:

- `linear` with `begin`, `end`, `colors`, optional `stops`
- `radial` with `center`, `radius`, `colors`, optional `stops`
- `sweep` with `center`, `startAngle`, `endAngle`, `colors`, optional `stops`

### Step 3: Local automation after export

Once manual export works, automate the local part:

1. Save plugin export to a known file (for example `figma-export.json`).
2. Add a small transform script that converts plugin JSON to this project schema.
3. Script writes final JSON to [lib/core/design_system/generator/tokens.json](lib/core/design_system/generator/tokens.json).
4. Script runs [lib/core/design_system/generator/generate_tokens.dart](lib/core/design_system/generator/generate_tokens.dart).
5. Script runs generator tests.

This gives: Figma export -> transform -> generate -> validate.

### Step 4: Full automatic sync (true end goal)

To make it automatic from Figma to Flutter without manual copy/paste, yes, you need one of these:

- A custom Figma plugin you build, or
- A plugin that can sync to an external source (GitHub/HTTP endpoint) plus a local pull script.

Important limitation:

- Figma plugins cannot directly write into your local Flutter project folder for security reasons.

So full automation usually looks like:

1. Designer clicks sync/export in Figma plugin.
2. Plugin pushes JSON to remote storage (repo, API, or hosted JSON file).
3. Local script/CI pulls latest JSON.
4. Transform + generator run automatically.
5. Flutter app updates.

### Recommended path for this repo

1. Start with manual export into [lib/core/design_system/generator/tokens.json](lib/core/design_system/generator/tokens.json).
2. Confirm generator + tests pass.
3. Add transform script.
4. Add remote sync.
5. Later build custom plugin only if needed.

## Other Figma Tokens You May Add Next

Besides colors and gradients, common exports from Figma that are useful for Flutter:

- Effects / shadows (single and layered shadows)
- Opacity tokens
- Blur tokens
- Border width/style tokens
- Motion tokens (duration, curve names)
- Elevation aliases
- Breakpoints and layout grid tokens
- Z-index/layer order tokens

Current generator fully supports colors, gradients, spacing, radius, typography, and dimensions.
