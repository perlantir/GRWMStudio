# GRWM-856 VERIFY

## Scope
- Added `GRWMStudio/Resources/Localizable.xcstrings`
- Added localization audit script and pre-commit hook
- Wired localization audit into CI
- Replaced remaining hardcoded user-facing literals in this slice
- Added Locker pluralized accessibility copy

## Static Verification
- `xcodegen generate` — PASS
- `swiftlint --strict --config .swiftlint.yml` — PASS
- `./Scripts/check-localization.sh` — PASS
- `./Scripts/verify-deepar-isolation.sh` — PASS
- `xcrun xcstringstool compile GRWMStudio/Resources/Localizable.xcstrings` — PASS

## Focused Test Pass
- `xcodebuild test -scheme GRWMStudio -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.3.1' -only-testing:GRWMStudioTests/ProfileRecordTests -only-testing:GRWMStudioTests/OnboardingStateTests -only-testing:GRWMStudioTests/SettingsPreferencesTests` — PASS

## Manual Simulator Smoke
- Looks library text surface rendered with localized copy:
  - `docs/qa/per-ticket/GRWM-856/looks-screen.jpg`
- Relaunch with `-GRWMDebugStartLocker` kept the app process alive and logging, but Simulator sometimes remained on the home/app-switcher visual snapshot instead of foregrounding the app:
  - `docs/qa/per-ticket/GRWM-856/locker-launch-attempt.jpg`

## Notes
- The original ticket asked for empty `es` placeholders. In practice, compiling empty Spanish entries produces empty UI strings at runtime.
- To preserve the app's English-only shipping behavior while still scaffolding Spanish keys, `es` entries currently mirror the English source text with `state: new`.
- Dynamic look, feed, effect, and shade names retain code-level fallbacks so the UI stays readable even if catalog coverage changes later.
