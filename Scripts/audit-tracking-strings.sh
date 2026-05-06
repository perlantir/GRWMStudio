#!/bin/bash
set -euo pipefail

if rg -n 'Sentry|Crashlytics|Bugsnag|Firebase|AdMob|AppsFlyer|Adjust|Amplitude|Mixpanel|Segment' \
  GRWMStudio GRWMStudioTests GRWMStudioUITests project.yml .github --glob '!GRWMStudio/Resources/**'; then
  echo "Tracking/analytics SDK marker audit failed."
  exit 1
fi

echo "Tracking/analytics SDK marker audit passed."
