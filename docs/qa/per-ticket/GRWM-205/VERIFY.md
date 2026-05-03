# GRWM-205 Verify

Ticket: App shell with tab bar
Date: 2026-05-02
Simulator: iPhone 16 Pro, iOS 18.3.1 (`BFD7E422-B789-4380-9588-B952559B6A92`)

## Build And Static Checks

- `xcodegen generate` passed and regenerated `GRWMStudio.xcodeproj`.
- `./Scripts/lint.sh` passed. Output: `swiftlint.log`.
- `./Scripts/verify-deepar-isolation.sh` passed. Output: `deepar-isolation.log`.
- `xcodebuild -quiet build -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO` passed. Output: `xcodebuild-build.log`.
- XcodeBuildMCP `build_run_sim` passed and launched `app.grwmstudio.ios` in Simulator.

## Manual Smoke

- Confirmed completed-onboarding state routes to `AppShell`.
- Confirmed floating `DHTabBar` is visible over tab content, with Mirror, Looks, center FAB, Feed, and Locker.
- Tapped Mirror, Looks, Feed, and Locker. Each rendered its matching placeholder text and selected dot.
- Selected Feed, stopped the app, relaunched it, and confirmed Feed stayed selected via `dh_last_tab`.
- Tapped the center FAB and confirmed the shell returned to Mirror.
- Confirmed the DEBUG-only reset button remains available after replacing the old app placeholder.

## Screenshots

- `app-shell-mirror.png`
- `app-shell-looks.png`
- `app-shell-feed.png`
- `app-shell-locker.png`
- `app-shell-persisted-feed.png`
- `app-shell-fab-mirror.png`

## Notes

- The tab bar uses SF Symbols for now, matching the current design-system default until custom drawn tab icons land in a later asset/icon ticket.
- Device validation remains blocked by local signing setup; simulator validation was used for this UI-only ticket.
