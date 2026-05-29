#!/usr/bin/env bash
# dict.sh — Fuzzy offline English dictionary
# Usage:
#   ./dict.sh           — interactive fuzzy search
#   ./dict.sh <word>    — direct lookup (fuzzy fallback on no match)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DICT_TSV="${SCRIPT_DIR}/dictionary.tsv"
DICT_JSON="${SCRIPT_DIR}/webster/dictionary.json"

# ── Check dependencies ───────────────────────────────────────────────────────

check_dep() {
    if ! command -v "$1" &>/dev/null; then
        echo "Error: '$1' is required but not installed." >&2
        echo "Install it with: $2" >&2
        exit 1
    fi
}

check_dep fzf     "brew install fzf     (macOS) / sudo apt install fzf     (Debian/Ubuntu)"
check_dep python3 "brew install python3 (macOS) / sudo apt install python3 (Debian/Ubuntu)"

# ── Generate TSV if missing ──────────────────────────────────────────────────

if [[ ! -f "$DICT_TSV" ]]; then
    if [[ ! -f "$DICT_JSON" ]]; then
        echo "Error: ${DICT_JSON} not found." >&2
        echo "Did you initialise the submodule? Run:" >&2
        echo "  git submodule update --init" >&2
        exit 1
    fi

    echo "Generating dictionary.tsv from submodule (one-time)..."
    python3 "${SCRIPT_DIR}/build_tsv.py" "$DICT_JSON" "$DICT_TSV"
    echo "Done."
fi

# ── Direct lookup: dict.sh <word> ────────────────────────────────────────────

if [[ -n "$1" ]]; then
    word="${1,,}"
    result=$(grep -i "^${word}"$'\t' "$DICT_TSV" || true)

    if [[ -z "$result" ]]; then
        echo "No exact match for '${word}'. Close matches:" >&2
        grep -i "^${word}" "$DICT_TSV" 2>/dev/null \
            | head -10 \
            | awk -F'\t' '{printf "  %-20s %s\n", $1, substr($2, 1, 80)}' \
            || echo "  (none found)" >&2
        exit 1
    fi

    awk -F'\t' '{printf "\033[1m%s\033[0m\n%s\n", $1, $2}' <<< "$result"
    exit 0
fi

# ── Interactive fuzzy search ─────────────────────────────────────────────────

selected=$(
    fzf \
        --delimiter='\t' \
        --with-nth=1 \
        --preview='awk -F"\t" "{print \$2}" <<< {}' \
        --preview-window='down:4:wrap' \
        --prompt='dict> ' \
        --height=50% \
        --layout=reverse \
        --info=inline \
        --bind='ctrl-y:execute-silent(echo {1} | tr -d "\n" | pbcopy 2>/dev/null || echo {1} | tr -d "\n" | xclip -selection clipboard 2>/dev/null)+abort' \
        < "$DICT_TSV"
)

[[ -n "$selected" ]] && awk -F'\t' '{printf "\033[1m%s\033[0m\n%s\n", $1, $2}' <<< "$selected"
