# iTerm2 config (dotfiles)

## Goal
- Left Option behaves as Meta (Esc+), so tmux can use `M-...` bindings reliably.
- Right Option remains Normal to reduce conflicts with IME/Chinese input.

## Current settings (Profiles.json)
- Left Option Key Sends: **Esc+**
- Right Option Key Sends: **Normal**

## Color schemes
- Included: `Dracula.itermcolors`, `Kanagawa.itermcolors`, `Catppuccin-Mocha.itermcolors`
- Import: iTerm2 → Preferences → Profiles → Colors → Color Presets… → Import…

## Apply
### Recommended: load prefs from this folder
1. iTerm2 → Preferences → General → Preferences
2. Enable **Load preferences from a custom folder or URL**
3. Select: `~/dotfiles/iterm2`
4. Restart iTerm2

### Quick test
Run:

```sh
cat -v
```

- Press **Left Option + h** → should print something like `^[h` (ESC prefix).
- Press **Right Option + h** → should *not* include `^[`.
