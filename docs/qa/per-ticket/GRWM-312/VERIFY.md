# GRWM-312 Verify

Ticket: Pro-locked shade tap to Paywall handoff
Date: 2026-05-03
Device: iPhone 16 Pro simulator, iOS 18.3.1, portrait

## Scope

Wired `.license` errors from `MirrorViewModel` into the root coordinator, added parent-gate and paywall placeholder overlays, and preserved the underlying app route so Mirror state survives overlay dismissal.

## Manual Smoke

1. Launched the app with `-GRWMDebugAppShell` and no Pro entitlement.
2. Opened Lips, scrolled to the Pro section, and tapped Disco Brat.
3. Verified the parent gate placeholder appeared.
4. Tapped Done and verified the paywall placeholder appeared.
5. Tapped Done and verified the app returned to the Lips tray with Disco Brat unselected.
6. Terminated the app and relaunched with `-GRWMDebugAppShell -GRWMDebugHasPro`.
7. Opened Lips, scrolled to Disco Brat, tapped it, and verified it selected directly with no parent gate.

## Screenshots

- `parent-gate-placeholder.png`
- `paywall-placeholder.png`
- `return-lips-no-pro-selected.png`
- `debug-pro-disco-brat-applied.png`

## Command Evidence

- `xcodegen.log`: PASS
- `swiftlint.log`: PASS, 0 violations in 97 files
- `deepar-isolation.log`: PASS
- `xcodebuild-build.log`: PASS
- `xcodebuild-handoff-tests.log`: PASS
- `xcodebuild-full-test.log`: PASS
- `pro-handoff-smoke.log`: PASS

## Acceptance Notes

- `MirrorView` observes `lastError == .license`, starts the parent gate, and clears `lastError`.
- Parent gate Done routes to the paywall placeholder.
- Paywall Done dismisses the overlay and returns to the mirror.
- The overlay model keeps `coordinator.route == .app`, preserving Mirror state underneath.
- Debug Pro entitlement applies Disco Brat directly and bypasses the gate.
