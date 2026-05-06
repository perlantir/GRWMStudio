#!/bin/bash
set -euo pipefail

DESTINATION="${DESTINATION:-platform=iOS Simulator,name=iPhone 16}"

xcodebuild test \
  -scheme GRWMStudio \
  -destination "${DESTINATION}" \
  -only-testing:GRWMStudioTests/PerformanceTests \
  CODE_SIGNING_ALLOWED=NO |
  xcbeautify
