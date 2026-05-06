#!/bin/bash
set -euo pipefail

UDID="${UDID:-FC58B5F0-CE16-415B-AE8C-1C42B1184EE3}"
OUTPUT_DIR="${OUTPUT_DIR:-docs/qa/maestro/$(date +%Y-%m-%d-%H%M%S)}"

mkdir -p "${OUTPUT_DIR}"
maestro test --device "${UDID}" --debug-output "${OUTPUT_DIR}/debug" --test-output-dir "${OUTPUT_DIR}/output" .maestro
