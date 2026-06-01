# fzdict

Offline English dictionary in your terminal, powered by [Webster's
Unabridged](https://github.com/adambom/dictionary) and
[fzf](https://github.com/junegunn/fzf).

## Setup

```bash
git clone --recurse-submodules <your-repo-url>
chmod +x fzdict.sh
```

If you already cloned without `--recurse-submodules`:

```bash
git submodule update --init
```

The first time you run `fzdict.sh` it generates `dictionary.tsv` from the submodule. This is a one-time step.

## Dependencies

- `fzf` — `brew install fzf` / `sudo apt install fzf`
- `python3` — for the one-time TSV generation

## Usage

```bash
./fzdict.sh                # interactive fuzzy search
./fzdict.sh <word>         # direct lookup (shows close matches if not found)
```

In interactive mode, `Ctrl+Y` copies the selected word to your clipboard.

## Repo structure

```
.
├── fzdict.sh         # main script
├── build_tsv.py      # converts dictionary.json → dictionary.tsv
├── dictionary.tsv    # generated on first run, gitignored
└── webster/          # submodule: adambom/dictionary
```

## .gitmodules

```
[submodule "webster"]
    path = webster
    url = https://github.com/adambom/dictionary
```
