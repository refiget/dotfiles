# Dotfiles

Personal dotfiles for macOS/Linux with a focus on a clean, keyboard-first workflow.

## What’s inside

- **tmux**: modular config + refined status bar UI + robust copy/paste
- **Neovim**: LSP-first setup with project venv auto-detection for Python
- **zsh (zimfw)**: modular zsh config + helpers (venv registry, OpenClaw helpers)
- **yabai**: macOS tiling window manager config
- **yazi**: file manager config (theme experiments may be reverted if unstable)

## Repo layout

```
.
├── README.md
├── README-nvim.md
├── README-tmux.md
├── README-zsh.md
├── deploy.sh
├── nvim/
├── tmux/
├── zsh/
├── yabai/
├── yazi/
└── scripts/
```

## Install

1) Clone:

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
```

2) Deploy symlinks:

```bash
./deploy.sh
```

3) Restart your shell / apps.

## Notes on philosophy (to avoid doc rot)

- The detailed, authoritative source of truth is the config itself.
- READMEs are intentionally **high-level**, and include only the parts that matter day-to-day.
- For tmux bindings, prefer inspection:

```bash
tmux list-keys
```

## Component docs

- Neovim → **README-nvim.md**
- tmux → **README-tmux.md**
- zsh → **README-zsh.md**

## Troubleshooting quick hits

- tmux: `tmux source-file ~/.tmux.conf`
- nvim: `nvim --clean` to compare against baseline
- zsh: `exec zsh` and check `zsh -x ~/.zshrc`
