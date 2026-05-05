#!/bin/bash

set -euo pipefail

python3 - <<'PY'
from pathlib import Path
import re
import sys

ROOT = Path("GRWMStudio")
SKIP_FILES = {
    "GRWMStudio/DesignSystem/Stickers/GRWMLogo.swift",
}
STRING_PATTERNS = [
    re.compile(r'Text\("([^"]+)"'),
    re.compile(r'Button\("([^"]+)"'),
    re.compile(r'Label\("([^"]+)"'),
    re.compile(r'\.navigationTitle\("([^"]+)"'),
    re.compile(r'DHButton\(title:\s*"([^"]+)"'),
    re.compile(r'\.accessibilityLabel\(Text\("([^"]+)"\)\)'),
]
LOCALIZATION_KEY = re.compile(r"^[a-z0-9]+(?:[._-][a-z0-9]+)+$")
SYMBOL_ONLY = re.compile(r"^[^A-Za-z]+$")
BRAND_ONLY = {"GRWM", "STUDIO"}

def strip_preview_blocks(text: str) -> str:
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

def is_allowed_literal(value: str) -> bool:
    if LOCALIZATION_KEY.fullmatch(value):
        return True
    if value in BRAND_ONLY:
        return True
    if SYMBOL_ONLY.fullmatch(value):
        return True
    if value.startswith("\\(") and value.endswith(")"):
        return True
    if "\\(" in value and not re.search(r"[A-Za-z]", value):
        return True
    return False

hits: list[str] = []

for path in sorted(ROOT.rglob("*.swift")):
    relative = path.as_posix()
    if relative in SKIP_FILES or relative.endswith("Tests.swift"):
        continue

    text = strip_preview_blocks(path.read_text())
    for line_number, line in enumerate(text.splitlines(), start=1):
        for pattern in STRING_PATTERNS:
            for match in pattern.finditer(line):
                value = match.group(1)
                if is_allowed_literal(value):
                    continue
                hits.append(f"{relative}:{line_number}:{value}")

if hits:
    print(f"Found {len(hits)} hardcoded user-facing strings:")
    for hit in hits:
        print(hit)
    sys.exit(1)

print("No hardcoded user-facing strings found.")
PY
