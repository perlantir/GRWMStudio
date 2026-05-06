# GRWM-857 Visual QA Inventory

Date: 2026-05-05
Owner: Codex

This folder is the manual visual comparison workspace for GRWM-857. The screenshot inventory script runs the first-party XCUITest flows that cover the current screen families and stores the `.xcresult` bundle plus a command log.

## Commands

```bash
./Scripts/screenshot-all-screens.sh
```

Use `DESTINATION='platform=iOS Simulator,name=iPhone 16,OS=latest'` to override the simulator target if needed.

## Screen Checklist

- [ ] Splash
- [ ] Welcome
- [ ] Parent info
- [ ] Permissions request
- [ ] Permissions denied
- [ ] App shell mirror
- [ ] Mirror skin tray
- [ ] Mirror base tray
- [ ] Mirror eyes tray
- [ ] Mirror brows tray
- [ ] Mirror cheeks tray
- [ ] Mirror lips tray
- [ ] Mirror looks tray
- [ ] Countdown overlay
- [ ] Recording overlay
- [ ] Pro gate handoff
- [ ] Photo preview
- [ ] Video preview
- [ ] Saved confetti
- [ ] Save/share
- [ ] Looks library
- [ ] Look detail
- [ ] Tutorial
- [ ] Locker empty
- [ ] Locker at limit
- [ ] Locker grid
- [ ] Locker detail
- [ ] Profile
- [ ] Feed
- [ ] Parent math gate
- [ ] Parent hold gate
- [ ] Paywall
- [ ] Settings
- [ ] Error variants, all 9

## Notes

GRWM-857 is kept first-party in this pass. Formal SnapshotTesting wiring and committed reference PNGs remain the explicit Phase 11 task in GRWM-902, so no new third-party dependency is introduced here.
