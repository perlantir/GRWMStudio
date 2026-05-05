#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/docs/qa/per-ticket/GRWM-854}"
DERIVED_DATA_DIR="${DERIVED_DATA_DIR:-$HOME/Library/Developer/Xcode/DerivedData/GRWMStudio-gaekqbidenxyijcvejwmtvkrtuoa}"
CONFIGURATION="${CONFIGURATION:-Debug}"
PLATFORM="${PLATFORM:-iphonesimulator}"
DEVICE="${DEVICE:-iPhone 16 (18.3.1)}"
TEMPLATE="${TEMPLATE:-Time Profiler}"
DURATION="${DURATION:-30s}"
TRACE_BASENAME="${TRACE_BASENAME:-$(echo "$TEMPLATE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')}"
TRACE_PATH="${TRACE_PATH:-$OUTPUT_DIR/$TRACE_BASENAME.trace}"
APP_PATH="${APP_PATH:-$DERIVED_DATA_DIR/Build/Products/${CONFIGURATION}-${PLATFORM}/GRWMStudio.app}"
BUNDLE_ID="${BUNDLE_ID:-app.grwmstudio.ios}"
SEED_ONBOARDING_DEFAULTS="${SEED_ONBOARDING_DEFAULTS:-1}"

mkdir -p "$OUTPUT_DIR"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Missing app bundle at $APP_PATH"
  echo "Build GRWMStudio for ${PLATFORM} first or pass APP_PATH=/absolute/path/to/GRWMStudio.app"
  exit 1
fi

echo "Recording template: $TEMPLATE"
echo "Device: $DEVICE"
echo "Duration: $DURATION"
echo "App: $APP_PATH"
echo "Trace: $TRACE_PATH"

if [[ "$PLATFORM" == "iphonesimulator" && "$SEED_ONBOARDING_DEFAULTS" == "1" ]]; then
  xcrun simctl terminate booted "$BUNDLE_ID" >/dev/null 2>&1 || true
  xcrun simctl spawn booted defaults write "$BUNDLE_ID" dh_onboarding_complete -bool YES
  xcrun simctl spawn booted defaults write "$BUNDLE_ID" dh_last_tab mirror
  echo "Seeded simulator defaults for app shell profiling."
fi

xcrun xctrace record \
  --template "$TEMPLATE" \
  --device "$DEVICE" \
  --time-limit "$DURATION" \
  --output "$TRACE_PATH" \
  --launch -- \
  "$APP_PATH"

echo "Saved trace to $TRACE_PATH"
