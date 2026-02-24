# Dotfiles (macOS)

A keyboard-first macOS setup focused on a clean terminal workflow: **tmux + Neovim + Yazi + Lazygit**.

## Highlights

- **Terminal**: iTerm2 · Catppuccin Mocha · Berkeley Mono v2 (primary) · Maple Mono (Nerd Font)
- **Shell**: zsh + zimfw
- **Editor**: Neovim (lazy.nvim, LSP, formatting)
- **File manager**: Yazi
- **Git UI**: Lazygit
- **Window manager**: yabai + borders (JankyBorders)

## Screenshots

### Terminal

![](assets/Terminal.png)

### Split (nvim + yazi + lazygit)

![](assets/spllit.png)

### Yazi + Lazygit

<table>
  <tr>
    <td width="50%"><strong>Yazi</strong></td>
    <td width="50%"><strong>Lazygit</strong></td>
  </tr>
  <tr>
    <td><img src="assets/yazi.png" alt="Yazi" /></td>
    <td><img src="assets/lazigit.png" alt="Lazygit" /></td>
  </tr>
</table>

## What’s included

- **tmux**: modular config + status bar + helper scripts (clipboard, session manager, fzf panes)
- **Neovim**: lazy.nvim + LSP + formatting (conform/none-ls)
- **zsh (zimfw)**: modular loader + prompt + completions
- **yabai**: tiling config + focus border via `borders`
- **yazi**: theme + small overrides
- **lazygit**: config synced via deploy

## Repository layout

```
.
├── README.md
├── README-nvim.md
├── README-tmux.md
├── README-zsh.md
├── assets/
├── borders/
├── deploy.sh
├── iterm2/
├── jupyter/
├── lazygit/
├── nvim/
├── qutebrowser/
├── sketchybar/
├── starship/
├── tmux/
├── yabai/
├── yazi/
└── zsh/
```

## Installation

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
./deploy.sh
```

`deploy.sh` creates symlinks into common locations (e.g. `~/.config/*`, `~/.zshrc`, `~/.tmux.conf`).

## Docs

- Neovim → **README-nvim.md**
- tmux → **README-tmux.md**
- zsh → **README-zsh.md**

## Quick reloads

- tmux: `tmux source-file ~/.tmux.conf`
- zsh: `exec zsh`

## Notes

- This repo is macOS-first.
- Some components (e.g. yabai scripting addition) may require extra system permissions.
