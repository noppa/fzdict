#!/usr/bin/env bash
# dict.sh — Fuzzy offline English dictionary
# Usage:
#   ./dict.sh           — interactive fuzzy search
#   ./dict.sh <word>    — direct lookup (fuzzy fallback on no match)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DICT_TSV="${SCRIPT_DIR}/dictionary.tsv"
DICT_SRC="${SCRIPT_DIR}/webster/dictionary.txt"

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
    if [[ ! -f "$DICT_SRC" ]]; then
        echo "Error: ${DICT_SRC} not found." >&2
        echo "Did you initialise the submodule? Run:" >&2
        echo "  git submodule update --init" >&2
        exit 1
    fi

    echo "Generating dictionary.tsv from submodule (one-time)..."
    python3 "${SCRIPT_DIR}/build_tsv.py" "$DICT_SRC" "$DICT_TSV"
    echo "Done."
fi

# ── Direct lookup: dict.sh <word> ────────────────────────────────────────────

query=""
if [[ -n "$1" ]]; then
    word="${1,,}"
    result=$(grep -i "^${word}"$'\t' "$DICT_TSV" || true)

    if [[ -n "$result" ]]; then
        awk -F'\t' '{printf "\033[1m%s\033[0m\n%s\n", $1, $2}' <<< "$result"
        exit 0
    fi

    query="$word"
fi

# ── Interactive fuzzy search ─────────────────────────────────────────────────

selected=$(
    fzf \
        --delimiter='\t' \
        --with-nth=1 \
        --query="$query" \
        --preview='printf "%s\n" {2}' \
        --preview-window='right:60%:wrap' \
        --prompt='dict> ' \
        --height=50% \
        --layout=reverse \
        --info=inline \
        --bind='ctrl-y:execute-silent(echo {1} | tr -d "\n" | pbcopy 2>/dev/null || echo {1} | tr -d "\n" | wl-copy 2>/dev/null || echo {1} | tr -d "\n" | xclip -selection clipboard 2>/dev/null)+abort' \
        < "$DICT_TSV"
)

if [[ -n "$selected" ]]; then
    selected_word=$(awk -F'\t' '{print $1}' <<< "$selected")
    printf '%s' "$selected_word" | pbcopy 2>/dev/null \
        || printf '%s' "$selected_word" | wl-copy 2>/dev/null \
        || printf '%s' "$selected_word" | xclip -selection clipboard 2>/dev/null \
        || true
    awk -F'\t' '{printf "\033[1m%s\033[0m\n%s\n", $1, $2}' <<< "$selected"
fi
