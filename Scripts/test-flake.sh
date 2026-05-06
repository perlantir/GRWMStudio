#!/bin/bash
set -euo pipefail

ITERATIONS="${ITERATIONS:-5}"
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 16}"

for iteration in $(seq 1 "${ITERATIONS}"); do
  echo "Flake pass ${iteration}/${ITERATIONS}"
  xcodebuild test \
    -scheme GRWMStudio \
    -destination "${DESTINATION}" \
    -only-testing:GRWMStudioTests \
    CODE_SIGNING_ALLOWED=NO |
    xcbeautify
done
