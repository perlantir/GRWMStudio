# GRWM-009 Verification

## Checks

- `./Scripts/lint.sh`: PASS, 0 SwiftLint violations.
- `./Scripts/verify-deepar-isolation.sh`: PASS.
- `xcodebuild build -scheme GRWMStudio -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'`: PASS.
- `xcodebuild test -scheme GRWMStudio -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'`: PASS, 7 total tests.
- XcodeBuildMCP `build_run_sim`: PASS on iPhone 16, iOS 26.4.
- Computer Use visual smoke: PASS, Simulator displayed pink gradient shell with `Splash placeholder`.

## Screenshots

- `splash-placeholder.png`
- `splash-placeholder.jpg` (optimized XcodeBuildMCP capture from the same simulator run)

## Notes

- The first build caught Swift 6 actor-isolation issues with environment defaults.
- `AppEnvironment` is nonisolated because it is only a service container at this stage.
- `RootCoordinator` remains `@MainActor @Observable`; its SwiftUI environment default uses an explicit key.
