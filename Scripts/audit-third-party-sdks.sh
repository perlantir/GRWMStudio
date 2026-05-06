#!/bin/bash
set -euo pipefail

allowed='^(AVFAudio|AVFoundation|AVKit|CoreHaptics|CoreMedia|CoreText|CryptoKit|DeepAR|Foundation|OSLog|Observation|Photos|StoreKit|SwiftData|SwiftUI|UIKit|UserNotifications)$'

failures=()
while IFS= read -r module; do
  if [[ ! "$module" =~ $allowed ]]; then
    failures+=("$module")
  fi
done < <(rg '^import ' GRWMStudio --glob '*.swift' | sed 's/.*import //' | sort -u)

if (( ${#failures[@]} > 0 )); then
  echo "Found non-approved app imports:"
  printf '  %s\n' "${failures[@]}"
  exit 1
fi

echo "Third-party SDK audit passed: only DeepAR and system frameworks are imported by the app target."
