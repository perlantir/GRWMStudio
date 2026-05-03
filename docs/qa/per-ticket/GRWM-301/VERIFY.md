# GRWM-301 Verify

Ticket: GRWM-301 - MirrorViewModel + state machine
Date: 2026-05-03
Simulator: iPhone 16 Pro, iOS 18.3.1 (`BFD7E422-B789-4380-9588-B952559B6A92`)

## Commands

- `xcodegen generate` - PASS (`xcodegen.log`)
- `./Scripts/lint.sh` - PASS, 0 violations across 72 Swift files (`swiftlint.log`)
- `./Scripts/verify-deepar-isolation.sh` - PASS (`deepar-isolation.log`)
- `xcodebuild -quiet build -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO` - PASS (`xcodebuild-build.log`)
- `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' -only-testing:GRWMStudioTests/MirrorViewModelTests CODE_SIGNING_ALLOWED=NO` - PASS (`xcodebuild-mirror-tests.log`)
- `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' -resultBundlePath docs/qa/per-ticket/GRWM-301/FullTests.xcresult CODE_SIGNING_ALLOWED=NO` - PASS (`xcodebuild-full-test.log`; local `.xcresult` generated but not committed)

## Live Smoke

- Built and launched with XcodeBuildMCP on the iPhone 16 Pro simulator.
- Computer Use visual check confirmed the app opened on the Mirror tab and showed the Dreamhouse mirror chrome with the simulator Magic Mirror placeholder.
- Tapped Looks tab, then tapped Mirror tab again. The lifecycle log showed `Camera stopped` on tab-away and `Mirror using simulator DeepAR placeholder` on return.

## Screenshots

- `mirror-running.png` - Mirror tab after launch.
- `looks-tab.png` - Tab-away smoke check.
- `mirror-return.png` - Mirror tab after returning.

## Acceptance Notes

- `MirrorState` is now the standalone state enum with `.failed(ErrorVariant)`.
- `SlotSelection` is the source-of-truth selection record for slot effect ID, shade, and Pro state.
- `MirrorViewModelTests` cover shade selection, parameter application through `DeepARController`, Pro gating, look override clearing, slot clear, and face visibility stream updates.
- Live red-lip overlay could not be validated in this simulator because the app intentionally uses the simulator DeepAR placeholder after the prior simulator license failure. Runtime calls are validated with a bootstrapped mock `DeepARClient`; real overlay validation remains a device gate.
