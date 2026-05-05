#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCHEME="GRWMStudio"
SIMULATOR_ID="FC58B5F0-CE16-415B-AE8C-1C42B1184EE3"
OUT_DIR="${1:-$ROOT/docs/qa/error-screenshots}"
RESULT_BUNDLE="${RESULT_BUNDLE:-$ROOT/build/GRWM-808.xcresult}"
EXPORT_DIR="$(mktemp -d "${TMPDIR:-/tmp}/grwm-error-export.XXXXXX")"

mkdir -p "$OUT_DIR"
rm -f "$OUT_DIR"/*.png
rm -rf "$RESULT_BUNDLE"

cd "$ROOT"
xcodegen generate
xcrun simctl boot "$SIMULATOR_ID" >/dev/null 2>&1 || true

xcodebuild test \
  -scheme "$SCHEME" \
  -destination "id=$SIMULATOR_ID" \
  CODE_SIGNING_ALLOWED=NO \
  -resultBundlePath "$RESULT_BUNDLE" \
  -only-testing:GRWMStudioUITests/ErrorScreenshotsUITests

xcrun xcresulttool export attachments \
  --path "$RESULT_BUNDLE" \
  --output-path "$EXPORT_DIR" >/dev/null

/usr/bin/python3 - <<'PY' "$EXPORT_DIR/manifest.json" "$EXPORT_DIR" "$OUT_DIR"
import json
import pathlib
import shutil
import sys

manifest_path = pathlib.Path(sys.argv[1])
export_dir = pathlib.Path(sys.argv[2])
out_dir = pathlib.Path(sys.argv[3])

entries = json.loads(manifest_path.read_text())
for test in entries:
    for attachment in test.get("attachments", []):
        exported = attachment.get("exportedFileName", "")
        suggested = attachment.get("suggestedHumanReadableName", "")
        if not exported.endswith(".png"):
            continue
        if "_0_" not in suggested:
            continue

        slug = suggested.split("_0_", 1)[0]
        src = export_dir / exported
        dst = out_dir / f"{slug}.png"
        shutil.copyfile(src, dst)
PY

rm -rf "$EXPORT_DIR"

echo "Saved error screenshots to $OUT_DIR"
