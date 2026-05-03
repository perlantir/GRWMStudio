#!/bin/sh
if which swiftlint > /dev/null; then
  swiftlint --strict
else
  echo "warning: SwiftLint not installed. brew install swiftlint"
  exit 0
fi
