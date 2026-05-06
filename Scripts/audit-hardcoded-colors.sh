#!/bin/bash
set -euo pipefail

python3 - <<'PY'
from pathlib import Path
import re
import sys

allowed_files = {
    "GRWMStudio/DesignSystem/Color+Hex.swift",
    "GRWMStudio/DesignSystem/DH+Tokens.swift",
    "GRWMStudio/DesignSystem/DHWallpaper.swift",
    "GRWMStudio/Errors/ErrorTone.swift",
    "GRWMStudio/Profile/AvatarSwatch+Style.swift",
}
allowed_prefixes = (
    "GRWMStudio/Mirror/Shades+",
)
patterns = [
    re.compile(r"Color\(hex:"),
    re.compile(r"Color\(red:"),
    re.compile(r"#[0-9A-Fa-f]{6}"),
]

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
    if relative in allowed_files or any(relative.startswith(prefix) for prefix in allowed_prefixes):
        continue
    text = strip_previews(path.read_text())
    for line_number, line in enumerate(text.splitlines(), start=1):
        if any(pattern.search(line) for pattern in patterns):
            hits.append(f"{relative}:{line_number}:{line.strip()}")

if hits:
    print("Found hardcoded colors outside token/palette definition files:")
    print("\n".join(hits))
    sys.exit(1)

print("Hardcoded color audit passed.")
PY
