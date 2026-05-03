#!/bin/sh
# Fails the build if `import DeepAR` appears outside the DeepAR/ folder.
set -eu
OFFENDERS=$(grep -lr --include="*.swift" "^import DeepAR" GRWMStudio/ \
  | grep -v "^GRWMStudio/DeepAR/" || true)
if [ -n "$OFFENDERS" ]; then
  echo "error: DeepAR is imported outside GRWMStudio/DeepAR/:"
  echo "$OFFENDERS"
  exit 1
fi
