#!/bin/sh
if ! find GRWMStudio GRWMStudioTests GRWMStudioUITests -name "*.swift" -print -quit | grep -q .; then
  echo "No Swift files found; skipping SwiftLint."
  exit 0
fi

if which swiftlint > /dev/null; then
  swiftlint --strict
else
  echo "warning: SwiftLint not installed. brew install swiftlint"
  exit 0
fi
