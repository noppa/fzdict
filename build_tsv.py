#!/usr/bin/env python3
"""build_tsv.py — Convert Webster's dictionary.json to a TSV for fzf.

Usage:
    python3 build_tsv.py <input.json> <output.tsv>
"""

import json
import re
import sys


def clean(text: str) -> str:
    """Collapse whitespace and strip surrounding spaces."""
    return re.sub(r"\s+", " ", text).strip()


def main(src: str, dst: str) -> None:
    with open(src, encoding="utf-8") as f:
        data = json.load(f)

    skipped = 0
    written = 0

    with open(dst, "w", encoding="utf-8") as out:
        for word, definition in sorted(data.items()):
            word_clean = clean(word).lower()
            def_clean = clean(str(definition))

            if not word_clean or not def_clean or def_clean in ("null", "none", ""):
                skipped += 1
                continue

            out.write(f"{word_clean}\t{def_clean}\n")
            written += 1

    print(f"Written {written} entries ({skipped} skipped) → {dst}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <input.json> <output.tsv>", file=sys.stderr)
        sys.exit(1)

    main(sys.argv[1], sys.argv[2])
