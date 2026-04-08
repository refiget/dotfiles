# Dotfiles (macOS)

A keyboard-first macOS setup built around two complementary centers:

- Terminal workflow: tmux + Neovim + Yazi + Lazygit
- Personal information workflow: Emacs/Doom used only for Org notes, agenda, and scratchpad capture

This repo is less about collecting apps and more about keeping interaction patterns consistent across shell, editor, terminal multiplexer, and window management.

## System shape

### 1. Terminal core

Primary day-to-day coding flow:

- Terminal: Ghostty / iTerm2
- Shell: zsh + zimfw
- Multiplexer: tmux
- Editor: Neovim
- File manager: Yazi
- Git UI: Lazygit

### 2. Org core

Emacs is not a general-purpose code editor here.
It is reserved for:

- Org notes
- Org agenda / task review
- Inbox capture
- Scratchpad-style quick access

That split is intentional: Neovim handles code, Emacs handles personal information and planning.

## Highlights

- Consistent Vim-style movement across tools where possible
- Modular config layout with thin top-level loaders
- tmux clipboard flow unified through explicit bridge scripts
- yabai + Hammerspoon integration for fast window control
- Emacs scratchpad toggle for Org workflow
- Deploy script that symlinks configs into their expected macOS locations

## What’s included

- zsh: modular startup, aliases, keybindings, tool runtime helpers
- tmux: modular config, clipboard scripts, status bar, session-management helpers
- Neovim: lazy.nvim, LSP, language-specific workflow glue
- Doom Emacs: Org-focused setup with agenda, capture-oriented keybindings, and UI tuning
- yabai: tiling rules and space policy
- Hammerspoon: Emacs scratchpad control and automation glue
- Ghostty / iTerm2 / fastfetch / karabiner / sketchybar: terminal and desktop polish

## Repository layout

```text
.
├── README.md
├── deploy.sh
├── doom/
├── ghostty/
├── hammerspoon/
├── karabiner/
├── nvim/
├── tmux/
├── yabai/
├── yazi/
├── zsh/
├── scripts/
└── assets/
```

Top-level files such as `.zshrc`, `.tmux.conf`, and Doom `config.el` stay intentionally small; most real behavior lives in modular subdirectories.

## Installation

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
./deploy.sh
```

Optional:

```bash
./deploy.sh --force
./deploy.sh --lazy
```

What `deploy.sh` does:

- creates symlinks into `~/.config/*` and selected home-directory paths
- handles macOS-specific paths for apps like Ghostty and Lazygit
- keeps compatibility bridges where an app may read from more than one config path

## Quick reloads

- tmux: `tmux source-file ~/.tmux.conf`
- zsh: `exec zsh`
- Doom Emacs after module/package changes: `doom sync`

## Notes

- macOS-first setup
- Some components require extra permissions or external tools, especially yabai / Hammerspoon integrations
- README is intentionally high-level; the actual source of truth is the config itself
