# GRWM-808 VERIFY

Date: 2026-05-04
Target: iOS Simulator
Ticket: GRWM-808 - Error variant matrix QA + screenshots for App Store

## What I verified

1. The DEBUG-only Developer section in Settings exposes the `Error trigger` route.
2. `ErrorTriggerView` lists all 9 App Store packet variants and each trigger presents the full-screen `DHErrorView`.
3. `Scripts/capture-error-screenshots.sh` runs end-to-end, exports 9 screenshots, and names them by variant slug.
4. The exported screenshots cover:
   - `cam-denied`
   - `mic-denied`
   - `photo-denied`
   - `license`
   - `effect-fail`
   - `rec-fail`
   - `save-fail`
   - `no-face`
   - `low-storage`
5. The visible chip titles match the shipped variant slugs, for example `ERROR · CAM-DENIED` and `ERROR · LOW-STORAGE`.
6. The rendered shells match the shared error layout structure from `docs/design-source/v3/dh-screens-8.jsx`: close button, radial hero, sticker accent, variant chip, title/body copy, and dual CTA stack.

## Commands used

```sh
xcodegen generate
bash Scripts/capture-error-screenshots.sh
```

## Output artifacts

Export folder:

- `docs/qa/error-screenshots/cam-denied.png`
- `docs/qa/error-screenshots/mic-denied.png`
- `docs/qa/error-screenshots/photo-denied.png`
- `docs/qa/error-screenshots/license.png`
- `docs/qa/error-screenshots/effect-fail.png`
- `docs/qa/error-screenshots/rec-fail.png`
- `docs/qa/error-screenshots/save-fail.png`
- `docs/qa/error-screenshots/no-face.png`
- `docs/qa/error-screenshots/low-storage.png`

Result bundle:

- `build/GRWM-808.xcresult`

## Design/copy note

There is an upstream copy mismatch between `docs/design-source/v3/dh-screens-8.jsx` and `10-APPENDICES.md` for several CTA strings and stickers. The current app implementation follows `10-APPENDICES.md` / `ErrorVariant.swift`, which is the more explicit locked table for the nine shipped variants.

Examples:

- `mic-denied` primary CTA is `Open Settings` in the app, not `Turn on Microphone`
- `photo-denied` primary CTA is `Open Settings` in the app, not `Allow Photos`
- `low-storage` secondary CTA is `Manage Locker` in the app, not `Save anyway`

## Boundaries

- This ticket's screenshot harness is verified and stable.
- Snapshot tests for the 9 error variants are not in place yet. That work depends on the later snapshot-test infrastructure ticket in Phase 11 (`GRWM-902`), so GRWM-808 currently has live UI capture proof but not committed visual diff tests.
