# GRWM-300 Verify

Ticket: MirrorView shell + DeepARView mount
Date: 2026-05-02
Simulator: iPhone 16 Pro, iOS 18.3.1 (`BFD7E422-B789-4380-9588-B952559B6A92`)

## Build And Static Checks

- `xcodegen generate` passed and regenerated `GRWMStudio.xcodeproj`.
- `./Scripts/lint.sh` passed. Output: `swiftlint.log`.
- `./Scripts/verify-deepar-isolation.sh` passed. Output: `deepar-isolation.log`.
- `xcodebuild -quiet build -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO` passed. Output: `xcodebuild-build.log`.
- `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO -only-testing:GRWMStudioTests/MirrorViewModelTests` passed. Output: `xcodebuild-mirror-tests.log`.
- Full `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO` passed. Output: `xcodebuild-full-test.log`.

## Manual Smoke

- With camera denied, Mirror tab showed the chunky butter "Tap to allow camera" card and did not trigger the iOS camera prompt on appear.
- Tapping the butter card routed to the permissions screen. Screenshot: `mirror-permission-route.png`.
- With camera granted, Mirror tab rendered the V01 chrome, white camera ring, pink chunky shadow, and simulator Magic Mirror placeholder. Screenshot: `mirror-simulator-placeholder.png`.
- Tapping away to Looks and back to Mirror completed without a DeepAR alert. Structured log evidence: `sim-log-lifecycle.log`.

## Screenshots

- `mirror-permission-card.png`
- `mirror-permission-route.png`
- `mirror-simulator-placeholder.png`

## Notes

- The real device path still bootstraps DeepAR and starts camera on appear. The simulator path is intentionally contained behind `#if targetEnvironment(simulator)` and uses the existing `DeepARView` placeholder to avoid a simulator-only DeepAR license dialog. Real DeepAR license validation and live camera feed remain blocked by physical-device signing.
- The DEBUG onboarding reset affordance was moved off the Mirror tab and into placeholder tabs so it no longer overlaps Mirror chrome.
