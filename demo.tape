Output demo.gif

Set Shell "bash"
Set FontSize 22
Set Width 1280
Set Height 720
Set Theme "Dracula"
Set Padding 24

Sleep 1s

# Direct word lookup
Type "fzdict suspicious"
Sleep 0.5s
Enter
Sleep 3s

Type "clear"
Enter
Sleep 0.5s

# Another direct lookup
Type "fzdict ephemeral"
Sleep 0.5s
Enter
Sleep 3s

Type "clear"
Enter
Sleep 0.5s

# Interactive fuzzy search — open with no argument
Type "fzdict"
Sleep 0.5s
Enter
Sleep 1.5s

# Type a query to filter
Type "abstr"
Sleep 1s

# Navigate down a few results
Down
Sleep 0.3s
Down
Sleep 0.3s
Down
Sleep 0.8s

# Select a word (copies to clipboard + prints definition)
Enter
Sleep 2s

# Show that the word landed in the clipboard
Type "wl-paste"
Sleep 0.5s
Enter
Sleep 2s

Type "clear"
Enter
Sleep 0.5s

# Show no-match fallback: unknown word opens fzf pre-filled
Type "fzdict mercurial"
Sleep 0.5s
Enter
Sleep 1.5s

# fzf opens pre-filled with "mercurial", pick the first result
Enter
Sleep 3s
