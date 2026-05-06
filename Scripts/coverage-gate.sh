#!/bin/bash
set -euo pipefail

RESULT_BUNDLE="${1:-docs/qa/test-results/phase-11-unit.xcresult}"
MIN_COVERAGE="${MIN_CRITICAL_COVERAGE:-0.80}"

if [ ! -d "${RESULT_BUNDLE}" ]; then
  echo "Coverage result bundle not found: ${RESULT_BUNDLE}"
  exit 1
fi

coverage_json="$(mktemp)"
trap 'rm -f "${coverage_json}"' EXIT
xcrun xccov view --report --json "${RESULT_BUNDLE}" > "${coverage_json}"

python3 - "${MIN_COVERAGE}" "${coverage_json}" <<'PY'
import json
import sys

minimum = float(sys.argv[1])
with open(sys.argv[2], "r", encoding="utf-8") as handle:
    report = json.load(handle)
critical_parts = ("Mirror", "Capture", "Library", "Commerce")
critical_names = ("ViewModel", "Service", "Catalog", "Repository", "Entitlement")
totals = {name: {"covered": 0, "executable": 0} for name in critical_parts}
failures = []

for target in report.get("targets", []):
    if target.get("name") != "GRWMStudio.app":
        continue
    for file in target.get("files", []):
        path = file.get("path", "")
        folder = next((name for name in critical_parts if f"/{name}/" in path), None)
        if folder is None:
            continue
        if not any(name in path for name in critical_names):
            continue
        totals[folder]["covered"] += int(file.get("coveredLines", 0))
        totals[folder]["executable"] += int(file.get("executableLines", 0))

for folder, counts in totals.items():
    if counts["executable"] == 0:
        continue
    coverage = counts["covered"] / counts["executable"]
    print(f"{coverage * 100:6.2f}% GRWMStudio/{folder}/")
    if coverage < minimum:
        failures.append((folder, coverage))

if failures:
    print("\nCoverage gate failed:")
    for folder, coverage in failures:
        print(f"  {coverage * 100:6.2f}% GRWMStudio/{folder}/")
    sys.exit(1)

print(f"Coverage gate passed for critical folders at >= {minimum * 100:.0f}%.")
PY
