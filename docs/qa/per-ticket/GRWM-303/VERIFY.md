# GRWM-303 Verify

Ticket: GRWM-303 - Filter rail UI (category strip)
Date: 2026-05-03
Simulator: iPhone 16 Pro, iOS 18.3.1 (`BFD7E422-B789-4380-9588-B952559B6A92`)

## Commands

- `xcodegen generate` - PASS (`xcodegen.log`)
- `./Scripts/lint.sh` - PASS, 0 violations across 77 Swift files (`swiftlint.log`)
- `./Scripts/verify-deepar-isolation.sh` - PASS (`deepar-isolation.log`)
- `xcodebuild -quiet build -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO` - PASS (`xcodebuild-build.log`)
- `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' -only-testing:GRWMStudioTests/FilterCategoryTests CODE_SIGNING_ALLOWED=NO` - PASS (`xcodebuild-filter-tests.log`)
- `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' -only-testing:GRWMStudioUITests/GRWMStudioUITests/testFilterRailAccessibilityLabelsAndSelection CODE_SIGNING_ALLOWED=NO` - PASS (`xcodebuild-filter-ui-test.log`)
- `xcodebuild -quiet test -scheme GRWMStudio -destination 'id=BFD7E422-B789-4380-9588-B952559B6A92' CODE_SIGNING_ALLOWED=NO` - PASS (`xcodebuild-full-test.log`)

## Live Smoke

- Launched on simulator with XcodeBuildMCP and visually inspected through Computer Use.
- Verified the 7-chip rail appears above the custom tab bar/FAB area without overlapping the mirror viewport.
- Tapped Eyes and Looks. Selected chips animated to the larger deep-pink state with white label text.
- Swiped the rail horizontally; it scrolled naturally from Skin/Base/Eyes/Brows through Brows/Cheeks/Lips/Looks.
- Confirmed the Looks chip carries the always-visible butter star sticker.

## Accessibility

- Added UI automation coverage for `Skin filter category` and `Eyes filter category`.
- The UI test launches directly into the app shell via DEBUG-only `-GRWMDebugAppShell`, taps each label, and verifies `isSelected`.
- XcodeBuildMCP `snapshot_ui` returned only the host application node in this simulator session, so the UI test is the durable accessibility evidence for this ticket.

## Screenshots

- `filter-rail-initial.png` - first visible rail position.
- `filter-rail-selected-eyes.png` - selected chip deep-pink state.
- `filter-rail-scrolled-looks-star.png` - rail scrolled to reveal Looks and star sticker.
- `filter-rail-selected-looks.png` - Looks chip selected state.

## Acceptance Notes

- `FilterCategory` owns the seven categories, labels, emoji, and `EffectSlot` mapping.
- `MirrorViewModel.activeCategory` is observable and writable from the rail.
- `DHHaptics.light()` now uses `UIImpactFeedbackGenerator(style: .light)`; physical haptic sensation cannot be felt in Simulator, but the production call path is wired.
