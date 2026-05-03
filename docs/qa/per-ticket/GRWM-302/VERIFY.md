# GRWM-302 Verify

Ticket: GRWM-302 - License flow + bootstrap error variants
Date: 2026-05-03
Simulator: iPhone 16 Pro, iOS 18.3.1 (`BFD7E422-B789-4380-9588-B952559B6A92`)

## Commands

- `xcodegen generate` - PASS (`xcodegen.log`)
- `plutil -p GRWMStudio/Resources/Info.plist | rg 'DEEPAR_LICENSE_KEY'` - PASS (`info-plist-license-key.log`)
- `./Scripts/lint.sh` - PASS, 0 violations across 74 Swift files (`swiftlint.log`)
- `./Scripts/verify-deepar-isolation.sh` - PASS (`deepar-isolation.log`)
- `xcodebuild -quiet build -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' DEEPAR_LICENSE_KEY= CODE_SIGNING_ALLOWED=NO` - PASS (`xcodebuild-empty-license-build.log`)
- `xcodebuild -quiet build -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO` - PASS (`xcodebuild-build.log`)
- `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' -only-testing:GRWMStudioTests/DeepARLicenseTests CODE_SIGNING_ALLOWED=NO` - PASS (`xcodebuild-license-tests.log`)
- `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' -only-testing:GRWMStudioTests/MirrorViewModelTests CODE_SIGNING_ALLOWED=NO` - PASS (`xcodebuild-mirror-tests.log`)
- `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO` - PASS (`xcodebuild-full-test.log`)

## Live Smoke

- Built and launched with `DEEPAR_LICENSE_KEY=` via XcodeBuildMCP. App did not crash; Mirror showed the error card with `Mirror needs a restart` and `License check needs attention.`
- Captured structured app logs while relaunching the empty-key build. The mirror logger emitted `DeepAR license missing or empty`.
- Rebuilt and launched without the empty-key override. Mirror returned to the simulator Magic Mirror placeholder.

## Screenshots

- `license-invalid.png` - empty license key error card.
- `license-valid-placeholder.png` - configured key path returns to the simulator mirror placeholder.

## Acceptance Notes

- `DeepARLicense.key()` reads the generated Info.plist key `DEEPAR_LICENSE_KEY`.
- `RootCoordinator.ErrorVariant` now separates `.licenseInvalid` from `.license`, keeping DeepAR bootstrap failure copy separate from Pro-entitlement flows.
- Bootstrap timeout is covered by `MirrorViewModelTests.testBootstrapTimeoutFailsWithEffectFailVariant` using a non-initializing DeepAR client and maps to `.failed(.effectFail)`.
- Simulator remains on the intentional DeepAR placeholder path after successful key load; real DeepAR license validation still requires a signed physical-device run.
