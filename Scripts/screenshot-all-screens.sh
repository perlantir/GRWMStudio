#!/bin/bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 16,OS=latest}"
RESULT_BUNDLE="${RESULT_BUNDLE:-$ROOT/docs/qa/test-results/screen-inventory.xcresult}"
LOG_FILE="${LOG_FILE:-$ROOT/docs/qa/screen-comparisons/screenshot-all-screens.log}"

mkdir -p "$(dirname "$RESULT_BUNDLE")" "$(dirname "$LOG_FILE")"
rm -rf "$RESULT_BUNDLE"

cd "$ROOT"

set -o pipefail
xcodebuild test \
  -scheme GRWMStudio \
  -destination "$DESTINATION" \
  -only-testing:GRWMStudioUITests/GRWMStudioUITests/testLaunches \
  -only-testing:GRWMStudioUITests/GRWMStudioUITests/testFilterRailAccessibilityLabelsAndSelection \
  -only-testing:GRWMStudioUITests/GRWMStudioUITests/testPhotoPreviewLayoutControlsVisible \
  -only-testing:GRWMStudioUITests/GRWMStudioUITests/testVideoModeTapStartsAndStopsRecording \
  -only-testing:GRWMStudioUITests/GRWMStudioUITests/testFavoriteLooksButtonRoutesToLooksTab \
  -only-testing:GRWMStudioUITests/GRWMStudioUITests/testLooksSelectionDismissesTray \
  -only-testing:GRWMStudioUITests/SettingsPolishUITests/testSettingsLookAndFeelShowsSeparateSoundAndHapticsRows \
  -only-testing:GRWMStudioUITests/ErrorScreenshotsUITests/testCaptureAllErrorScreenshots \
  -only-testing:GRWMStudioUITests/AccessibilityUITests/testCaptureAccessibilityVisualEvidence \
  -resultBundlePath "$RESULT_BUNDLE" \
  CODE_SIGNING_ALLOWED=NO \
  2>&1 | tee "$LOG_FILE"

echo "Screen inventory result bundle: $RESULT_BUNDLE"
echo "Screen inventory log: $LOG_FILE"
