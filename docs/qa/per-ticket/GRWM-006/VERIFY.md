# GRWM-006 Verification

## Checks

- `./Scripts/lint.sh`: PASS, 0 SwiftLint violations.
- `./Scripts/verify-deepar-isolation.sh`: PASS.
- `xcodebuild build -scheme GRWMStudio -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'`: PASS.
- `xcodebuild test -scheme GRWMStudio -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'`: PASS, 7 total tests.

## Notes

- Sticker source paths were copied from `docs/design-source/v3/grwm-shared.jsx`.
- `GRWMLogo` includes the stack and row layouts plus the shared `stickerBob()` animation modifier.
- No app route renders these primitives yet; visual simulator smoke is covered when GRWM-010 wires the splash screen.
