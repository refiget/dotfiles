# zsh

Modular zsh config using **zimfw**. Designed to stay readable and easy to override.

## Highlights

- Modular config: `~/dotfiles/zsh/conf.d/*.conf`
- venv helpers:
  - `mkvenv` creates `./.venv` in the current directory
  - `venv <name>` activates from `~/venvs/registry.tsv` (name → project venv)
- OpenClaw helpers:
  - `oc <name>` opens TUI when interactive; sends message when piped
  - `ocstudy`, `ocwork` convenience aliases

## Files

- Loader: `~/.zshrc` → symlinked from `~/dotfiles/.zshrc`
- Profile: `~/.zprofile` → symlinked from `~/dotfiles/.zprofile`
- Zim config: `~/dotfiles/.zimrc`

## Local overrides

Put machine-specific tweaks in:

- `zsh/conf.d/08_local_overrides.conf`

This keeps the main config clean and portable.

## tmux integration

- Autostart tmux behavior (if enabled) lives in `zsh/conf.d/10_autostart_tmux.conf`.
- Mode→color syncing into tmux is **disabled** (it caused abrupt UI switching).
