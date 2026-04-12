# zsh

Modular zsh config using **zimfw**. Designed to stay readable and easy to override.

## Highlights

- Modular config: `~/dotfiles/zsh/conf.d/*.conf`
- Thin startup chain: `.zshenv` → `.zprofile` → `.zshrc`
- Deterministic `Ctrl-R`: Atuin when available, native zsh fallback otherwise
- `fzf` shell integration is loaded from exactly one provider
- venv helpers:
  - `mkvenv` creates `./.venv` in the current directory
  - `venv <name>` activates from `~/venvs/registry.tsv` (name → project venv)
- OpenClaw helpers:
  - `oc <name>` opens TUI when interactive; sends message when piped
  - `ocstudy`, `ocwork` convenience aliases

## Startup files

- Loader: `~/.zshrc` → symlinked from `~/dotfiles/.zshrc`
- Universal env: `~/.zshenv` → symlinked from `~/dotfiles/.zshenv`
- Login profile: `~/.zprofile` → symlinked from `~/dotfiles/.zprofile`
- Zim config: `~/dotfiles/.zimrc`

## Local hooks

Use machine-specific tweaks in one of these hooks:

- `~/.zshrc.pre.local`
  - loaded by `zsh/conf.d/80_local_overrides.conf`
  - use this for variables that later modules need to read before acting, e.g.:
    - `export ZSH_SKIP_DEP_CHECKS=1`
    - `export ZSH_SKIP_TMUX_AUTOSTART=1`
- `~/.zshrc.local`
  - loaded by `zsh/conf.d/99_local_overrides.conf`
  - use this for final aliases, bindings, prompt tweaks, or last-stage overrides

Note: `zsh/conf.d/95_autostart_tmux.conf` may `exec tmux`, so the final `~/.zshrc.local` hook is only reached when startup continues past tmux autostart.

## tmux integration

- Autostart tmux behavior lives in `zsh/conf.d/95_autostart_tmux.conf`.
- Disable it from the early hook with `export ZSH_SKIP_TMUX_AUTOSTART=1`.
- Mode→color syncing into tmux is **disabled** (it caused abrupt UI switching).
