# GRWM-853 VERIFY

Date: 2026-05-04
Ticket: `GRWM-853 — Accessibility pass`

## Verified

- Added accessibility labels, hints, and selected-state announcements across the core Dreamhouse controls and high-traffic surfaces.
- Hid decorative-only elements from accessibility where required, including face-tracking dots and wallpaper/sticker chrome.
- Clamped Dynamic Type at the app root to `accessibility2` and tuned AX-specific layout behavior for the tab bar, mirror trays, capture chrome, and feed cards.
- Added automated contrast auditing in `Scripts/audit-contrast.swift`.
- Added automated hit-target/source-marker coverage in `GRWMStudioTests/HitTargetTests.swift`.
- Added UI-level accessibility coverage and AX2 screenshot capture in `GRWMStudioUITests/AccessibilityUITests.swift`.

## Command Results

### Contrast audit

```bash
swift Scripts/audit-contrast.swift
```

Result: `PASS` with `0 failures`.

### SwiftLint

```bash
swiftlint --strict --config .swiftlint.yml
```

Result: `PASS` with `0 violations`.

### DeepAR isolation audit

```bash
bash Scripts/verify-deepar-isolation.sh
```

Result: `PASS`.

### Accessibility tests

```bash
xcodebuild test -scheme GRWMStudio \
  -destination 'id=FC58B5F0-CE16-415B-AE8C-1C42B1184EE3' \
  CODE_SIGNING_ALLOWED=NO \
  -only-testing:GRWMStudioTests/AccessibilitySnapshotTests \
  -only-testing:GRWMStudioTests/HitTargetTests \
  -only-testing:GRWMStudioUITests/AccessibilityUITests
```

Result: `PASS`.

Executed:

- `AccessibilitySnapshotTests` — 3/3 pass
- `HitTargetTests` — 2/2 pass
- `AccessibilityUITests` — 5/5 pass

xcresult:

- `/Users/perlantir/Library/Developer/Xcode/DerivedData/GRWMStudio-gaekqbidenxyijcvejwmtvkrtuoa/Logs/Test/Test-GRWMStudio-2026.05.04_22-04-30--0500.xcresult`

## Visual Smoke

Simulator destination:

- `iPhone 16`
- UDID `FC58B5F0-CE16-415B-AE8C-1C42B1184EE3`

Performed a manual simulator smoke pass and an automated AX2 screenshot pass after the layout fixes. The refreshed evidence shows the tab bar, capture mode picker, mirror trays, and feed labels no longer colliding at accessibility sizes.

Artifacts:

- `error-no-face-ax2.png`
- `mirror-default-ax2.png`
- `skin-tray-ax2.png`
- `feed-ax2.png`

## Notes

- The repo's current capture interaction follows the newer product direction of explicit photo/video mode selection plus tap-to-capture, not the older ticket text that mentions triple-tap-and-hold video recording. The accessibility copy and tests were aligned to the shipped interaction model in the current app shell.
- Verification is strong on labels, hints, selected-state values, Dynamic Type behavior, contrast, hit targets, and AX2 visual layout. This pass did not include a literal end-to-end spoken VoiceOver audio walkthrough of every screen; instead it used UI accessibility assertions plus simulator visual review.
