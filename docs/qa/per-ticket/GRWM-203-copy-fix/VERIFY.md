# GRWM-203 Copy Fix Verify

Ticket: GRWM-203 follow-up found during Phase 2 signoff
Date: 2026-05-02
Simulator: iPhone 16 Pro, iOS 18.3.1 (`BFD7E422-B789-4380-9588-B952559B6A92`)

## Change

- Replaced the Photos add-only permission copy that said "show your friends" with a COPPA-safer local-save statement:
  `GRWM Studio adds saved looks to Photos only when you tap Save.`
- Updated `project.yml`, generated `GRWMStudio/Resources/Info.plist`, and the local DeepAR/spec docs so future ticket work does not reintroduce the old wording.

## Verification

- `xcodegen generate` passed and regenerated `GRWMStudio.xcodeproj`.
- `./Scripts/lint.sh` passed. Output: `swiftlint.log`.
- `xcodebuild -quiet build -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO` passed. Output: `xcodebuild-build.log`.
- Social-copy scan passed for the edited app/config/doc surfaces. Output: `social-copy-scan.log`.
- Reset `photos-add` permission on the simulator, relaunched onboarding with `-GRWMDebugOnboardingFlow`, tapped Photos Allow, and confirmed the system prompt shows the new local-save copy.

## Screenshot

- `photos-prompt-coppa-copy.png`
