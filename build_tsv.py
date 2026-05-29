#!/usr/bin/env python3
"""build_tsv.py — Convert Webster's dictionary.txt to a TSV for fzf.

Parses the plain-text source directly, joining wrapped lines with spaces,
instead of using the pre-built dictionary.json (which has missing spaces at
line joins due to CRLF handling in the original Julia build script).

Usage:
    python3 build_tsv.py <input.txt> <output.tsv>
"""

import re
import sys

HEADER_RE = re.compile(r'^[A-Z][A-Z\s\-_]*$')
NUMBERED_RE = re.compile(r'^\d+\.\s')


def clean(text: str) -> str:
    return re.sub(r'\s+', ' ', text).strip()


def parse_dictionary(txt_path: str) -> dict:
    with open(txt_path, encoding='utf-8', errors='replace') as f:
        lines = [line.rstrip('\r\n') for line in f]

    dictionary: dict[str, str] = {}
    word: str | None = None
    defining = False   # Defn: mode — stops collecting at blank line
    numbered = False   # numbered-def mode — stops only at next header
    defn_parts: list[str] = []

    def save() -> None:
        nonlocal word, defining, numbered, defn_parts
        if word is not None and defn_parts:
            dictionary[word] = ' '.join(defn_parts)
        word = None
        defining = False
        numbered = False
        defn_parts = []

    for line in lines:
        stripped = line.strip()

        if HEADER_RE.match(stripped) and stripped:
            save()
            if stripped not in dictionary:
                word = stripped
            continue

        if stripped.startswith('Defn:'):
            if word is not None:
                defining = True
                numbered = False
                rest = stripped[len('Defn:'):].strip()
                if rest:
                    defn_parts.append(rest)
            continue

        # Numbered definitions (1. 2. 3.) — only enter this mode when we
        # haven't already started a Defn: block, to avoid double-collecting.
        if NUMBERED_RE.match(stripped) and word is not None and not defining:
            numbered = True
            defn_parts.append(stripped)
            continue

        # Defn: mode stops at blank lines; numbered mode skips them.
        if stripped == '':
            if defining:
                save()
            continue

        if (defining or numbered) and word is not None:
            defn_parts.append(stripped)

    save()
    return dictionary


def main(src: str, dst: str) -> None:
    data = parse_dictionary(src)

    skipped = 0
    written = 0

    with open(dst, 'w', encoding='utf-8') as out:
        for word, definition in sorted(data.items()):
            word_clean = clean(word).lower()
            def_clean = clean(definition)

            if not word_clean or not def_clean or def_clean in ('null', 'none', ''):
                skipped += 1
                continue

            out.write(f'{word_clean}\t{def_clean}\n')
            written += 1

    print(f'Written {written} entries ({skipped} skipped) → {dst}')


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f'Usage: {sys.argv[0]} <input.txt> <output.tsv>', file=sys.stderr)
        sys.exit(1)

    main(sys.argv[1], sys.argv[2])
