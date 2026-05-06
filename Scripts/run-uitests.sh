#!/bin/bash
set -euo pipefail

DESTINATIONS=(
  "platform=iOS Simulator,name=iPhone 16"
  "platform=iOS Simulator,name=iPhone 16 Pro Max"
)

for destination in "${DESTINATIONS[@]}"; do
  echo "Running critical UI journeys on ${destination}"
  xcodebuild test \
    -scheme GRWMStudio \
    -destination "${destination}" \
    -only-testing:GRWMStudioUITests/CriticalJourneysUITests \
    -resultBundlePath "docs/qa/test-results/ui-critical-$(echo "${destination}" | tr ' =,' '---').xcresult" \
    CODE_SIGNING_ALLOWED=NO |
    xcbeautify
done
