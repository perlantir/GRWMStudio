#!/bin/bash
set -euo pipefail

python3 - <<'PY'
from pathlib import Path
import re
import sys

allowed_files = {
    "GRWMStudio/DesignSystem/DH+Fonts.swift",
}
custom_font_pattern = re.compile(r"\.font\(\.custom|Font\.custom")

def strip_previews(text: str) -> str:
    lines = text.splitlines()
    output = []
    skipping = False
    depth = 0
    for line in lines:
        if not skipping and line.lstrip().startswith("#Preview"):
            skipping = True
            depth = line.count("{") - line.count("}")
            continue
        if skipping:
            depth += line.count("{") - line.count("}")
            if depth <= 0:
                skipping = False
            continue
        output.append(line)
    return "\n".join(output)

hits = []
for path in sorted(Path("GRWMStudio").rglob("*.swift")):
    relative = path.as_posix()
    if relative in allowed_files:
        continue
    text = strip_previews(path.read_text())
    for line_number, line in enumerate(text.splitlines(), start=1):
        if custom_font_pattern.search(line):
            hits.append(f"{relative}:{line_number}:{line.strip()}")

if hits:
    print("Found raw custom font calls outside DH.font:")
    print("\n".join(hits))
    sys.exit(1)

print("Hardcoded font audit passed.")
PY
