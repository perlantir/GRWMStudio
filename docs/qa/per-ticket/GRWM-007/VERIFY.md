# GRWM-007 Verification

## Checks

- `./Scripts/lint.sh`: PASS, 0 SwiftLint violations.
- `./Scripts/verify-deepar-isolation.sh`: PASS.
- `xcodebuild build -scheme GRWMStudio -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'`: PASS.
- `xcodebuild test -scheme GRWMStudio -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'`: PASS, 7 total tests.

## Notes

- Added `DHButton` with 4 sizes and 5 kinds.
- Added `DHCard` with configurable `bg`, `deep`, corner radius, and padding.
- Added `DHChip` with selected/unselected states and expanded 44pt hit target.
- Added the temporary `DHHaptics` no-op stub for the later GRWM-851 replacement.
