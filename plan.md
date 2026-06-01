Here's a concise handoff summary you can paste to your local agent:

---

## Project: `fzdict` — Offline CLI dictionary

### What it is
A small shell tool for looking up English word spellings and definitions from the terminal, fully offline. Built for a non-native English speaker who wants something faster than Googling.

### Stack
- **`fzf`** for interactive fuzzy search
- **Python 3** for one-time data conversion
- **Webster's Unabridged Dictionary** (`adambom/dictionary` on GitHub) as the data source — public domain via Project Gutenberg, `{ "word": "definition" }` JSON format

### Repo structure
```
.
├── fzdict.sh           # main entry point (bash)
├── build_tsv.py      # converts webster/dictionary.json → dictionary.tsv
├── .gitmodules       # submodule: adambom/dictionary → webster/
├── .gitignore        # ignores dictionary.tsv (generated, not committed)
└── README.md
```

### How it works
1. `fzdict.sh` checks if `dictionary.tsv` exists next to itself
2. If not, calls `build_tsv.py webster/dictionary.json dictionary.tsv` to generate it (one-time)
3. Pipes the TSV into `fzf` with `--with-nth=1` (search by word) and `--preview` (shows definition)
4. `Ctrl+Y` copies selected word to clipboard (`pbcopy` / `xclip`)
5. `./fzdict.sh <word>` does a direct grep lookup, with a close-matches fallback

### TSV format
Tab-separated: `word\tdefinition` — one entry per line, words lowercased, whitespace normalised.

### Not yet done / possible next steps
- No `~/.local/bin` install step — user runs it directly as `./fzdict.sh` or symlinks it themselves
- Could add a `--install` flag or `Makefile` for convenience
- Webster's definitions are somewhat archaic; could consider supplementing with a modern source
- No handling for words with multiple definitions (Webster's JSON has one string per word)

