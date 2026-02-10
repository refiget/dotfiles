# tmux

Modular tmux config tuned for macOS, with a refined status bar and safer clipboard behavior.

## Highlights

- **Status bar UI**: centered tab strip, explicit badges (activity/bell/zoom), calmer typography.
- **Safer paste**: clipboard scripts strip trailing newlines to reduce accidental “paste + Enter”.
- **Copy-mode (vi)**: selection/copy bindings tuned for speed and minimal mode churn.
- **No scratchpad**: scratchpad feature removed entirely.

## Files & structure

- Loader: `~/.tmux.conf` (symlinked from `~/dotfiles/.tmux.conf`)
- Modular configs: `~/dotfiles/tmux/conf.d/*.conf`
- Scripts: `~/.config/tmux/scripts/` → symlinked to `~/dotfiles/tmux/scripts/`
- Status segments:
  - `~/dotfiles/tmux/tmux-status/left.sh`
  - `~/dotfiles/tmux/tmux-status/right.sh`

## Key operations

### Reload

```bash
tmux source-file ~/.tmux.conf
```

### Inspect bindings (source of truth)

```bash
tmux list-keys
```

### Clipboard behavior

- Copy to system clipboard uses `copy_to_clipboard.sh`
- Paste uses `paste_from_clipboard.sh`
- Both sanitize trailing newlines for safety.

## Status bar conventions

- **Mode colors are not used to theme the whole UI** (avoid abrupt switching).
- Dynamic indicators are limited to small, meaningful cues:
  - Window badges: activity/bell/zoom
  - Optional timer dot (breathing UI) on the right when enabled

## Dependencies (optional)

- `reattach-to-user-namespace` (older macOS setups)
- `pbcopy/pbpaste` (macOS clipboard)
