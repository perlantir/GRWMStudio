# GRWM-950 VERIFY

- Added `GRWMStudio/Resources/PrivacyInfo.xcprivacy` and regenerated the project so the manifest is copied into app resources.
- `plutil -lint GRWMStudio/Resources/PrivacyInfo.xcprivacy` -> OK.
- `xcodebuild build -scheme GRWMStudio -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO` -> BUILD SUCCEEDED.
- `xcodebuild test -scheme GRWMStudio -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.3.1' -only-testing:GRWMStudioTests/RootCoordinatorTests CODE_SIGNING_ALLOWED=NO` -> 5 tests passed.
- Simulator launch screenshot captured at `simulator-launch.jpg`.
- `xcrun --sdk iphoneos privacy-validation ...` could not be completed on this machine because the `privacy-validation` utility is not present in the installed Xcode toolchain.
