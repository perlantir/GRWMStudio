# GRWM-008 Verification

## Checks

- `./Scripts/lint.sh`: PASS, 0 SwiftLint violations.
- `./Scripts/verify-deepar-isolation.sh`: PASS.
- `xcodebuild build -scheme GRWMStudio -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'`: PASS.
- `xcodebuild test -scheme GRWMStudio -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'`: PASS, 7 total tests.

## Notes

- `DHWallpaperStripes` uses `Canvas` for 45-degree stripes.
- `DHWallpaperGradient` uses the `pinkPaper` to `cream` stop map from the design system.
- `DHWallpaperRadial` preserves the mirror viewport colors from the JSX/design-system radial spec.
