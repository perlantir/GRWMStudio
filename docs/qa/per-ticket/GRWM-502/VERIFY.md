# GRWM-502 Verify

## Scope

- Added the eye-shadow color set to eyeliner, lashes, and lipstick shade trays.
- Changed Base selections to use face makeup parameters instead of full-screen LUT parameters.
- Changed Skin selections to apply both face color and face amount so they visibly affect the face.

## Simulator Visual Smoke

- `simulator-base-face-only-shades.jpg`: Base tray shows None, Soft, Glow, and Glam face makeup choices.
- `simulator-skin-shades-visible.jpg`: Skin tray opens and shows complexion shades.
- `simulator-eyeliner-colors.jpg`: Eyeliner tray includes the added color swatches.
- `simulator-lashes-colors.jpg`: Lashes tray includes the added color swatches.
- `simulator-lashes-colors-right.jpg`: Lashes tray scrolls through Brown, Blue, and legacy styles.
- `simulator-lip-existing-shades.jpg`: Lips tray still shows the original lip shades.
- `simulator-lip-added-colors.jpg`: Lips tray scrolls to added Brown and Blue colors.

Simulator cannot validate live face tracking or makeup placement because it uses the placeholder mirror view.

## Commands

```sh
xcodebuild -quiet test -project GRWMStudio.xcodeproj -scheme GRWMStudio -destination 'platform=iOS Simulator,id=BFD7E422-B789-4380-9588-B952559B6A92' -only-testing:GRWMStudioTests/ShadeTests -only-testing:GRWMStudioTests/EffectParameterMapTests -only-testing:GRWMStudioTests/MirrorViewModelTests -only-testing:GRWMStudioTests/MirrorLipViewModelTests -only-testing:GRWMStudioTests/EffectCatalogTests
./Scripts/lint.sh
./Scripts/verify-deepar-isolation.sh
git diff --check
xcodebuild -quiet build -project GRWMStudio.xcodeproj -scheme GRWMStudio -configuration Debug -destination 'id=907E2EE7-9C7B-5D0D-9EC0-32E69912287D' -allowProvisioningUpdates
xcrun devicectl device install app --device 907E2EE7-9C7B-5D0D-9EC0-32E69912287D /Users/perlantir/Library/Developer/Xcode/DerivedData/GRWMStudio-gaekqbidenxyijcvejwmtvkrtuoa/Build/Products/Debug-iphoneos/GRWMStudio.app
```

## Results

- Targeted AR shade/filter tests: PASS.
- SwiftLint: PASS, 0 violations.
- DeepAR isolation audit: PASS.
- Whitespace diff check: PASS.
- Generic iOS Debug build: PASS.
- Physical iPhone Debug build: PASS.
- Physical iPhone install: PASS, bundle ID `app.grwmstudio.ios`.
- Physical iPhone live launch: BLOCKED because iOS reported the device was locked.
