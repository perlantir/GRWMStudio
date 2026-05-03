# GRWM-002 QA Evidence

## Build Phase

- Added a `SwiftLint` run script phase to the `GRWMStudio` target.
- The phase appears before `Compile Sources`.
- Dependency analysis is disabled, and Xcode reports that the phase runs every build.
- Input file list includes `$(SRCROOT)/.swiftlint.yml`.

## Verification

- `xcodebuild-build-pass.txt`: build passes and shows `[GRWMStudio] Running script SwiftLint`.
- `lint-violation-build-failure.txt`: deliberate `let lintProbe = "" as String!` violation fails the build in the SwiftLint phase with exit code `65`.
- `xcodebuild-build-final.txt`: after removing the probe, build passes again.
- `.github/workflows/ci.yml` calls `./Scripts/lint.sh`.
- `Scripts/lint.sh`: pass, 0 violations across 4 Swift files.
- `Scripts/verify-deepar-isolation.sh`: pass.
