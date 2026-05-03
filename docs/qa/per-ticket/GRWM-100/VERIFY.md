# GRWM-100 Verification

## Checks

- DeepAR SwiftPM package resolved: `https://github.com/DeepARSDK/swift-deepar` at `5.6.22`.
- Temporary `GRWMStudio/DeepAR/_smoketest.swift` compiled with `import DeepAR`: PASS on generic iOS device build.
- Temporary smoke file deleted after verification.
- `./Scripts/verify-deepar-isolation.sh`: PASS with smoke test and after deletion.
- Generic iOS device build with smoke test: PASS using `CODE_SIGNING_ALLOWED=NO`.
- iPhone 16 simulator build after deleting smoke test: PASS.

## Notes

- DeepAR 5.6.22 ships `ios-x86_64-simulator` and `ios-arm64` slices, but not an Apple Silicon `ios-arm64-simulator` slice.
- Simulator builds pass while no source references DeepAR symbols; real DeepAR import/link verification is recorded against the iOS device slice.
- Physical-device verification remains required before Phase 1 signoff for live SDK bootstrap and camera behavior.
