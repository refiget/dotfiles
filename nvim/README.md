# Neovim (macOS)

This folder contains the Neovim configuration used by this dotfiles repo.

- Entry point: `~/.config/nvim/init.lua`
- Plugin manager: `lazy.nvim` (`lua/config/lazy.lua`)
- LSP config: `lua/config/lsp.lua`

## Leaders

- `mapleader` = **Space**
- `maplocalleader` = **`,`**

Below tables list the most important custom shortcuts.

## Core editing / navigation

| Mode | Key               | Action                                        |
| ---- | ----------------- | --------------------------------------------- |
| n    | `;`               | Enter command-line (`:`)                      |
| n    | `Q`               | Quit (`:q`)                                   |
| n    | `Y`               | Yank current line to system clipboard (`+yy`) |
| v    | `Y`               | Yank selection to system clipboard (`+y`)     |
| n    | `<leader><CR>`    | Clear search highlight (`:nohlsearch`)        |
| n/x  | `J`               | Move 5 lines down                             |
| n/x  | `K`               | Move 5 lines up                               |
| n    | `<leader>h/j/k/l` | Move to window left/down/up/right             |
| t    | `<C-n>`           | Exit terminal-mode to normal-mode             |

## Tabs

| Mode | Key  | Action              |
| ---- | ---- | ------------------- |
| n    | `gt` | Next tab (wrap)     |
| n    | `gT` | Previous tab (wrap) |

## File explorer

| Mode | Key         | Action                           |
| ---- | ----------- | -------------------------------- |
| n    | `<leader>e` | Toggle file explorer (nvim-tree) |

## Search (Telescope)

| Mode | Key         | Action                                                      |
| ---- | ----------- | ----------------------------------------------------------- |
| n    | `<leader>w` | Find files (Projects/dotfiles), open selection in a new tab |
| n    | `<leader>g` | Live grep (Projects/dotfiles)                               |

## LSP (Lspsaga)

| Mode | Key          | Action                 |
| ---- | ------------ | ---------------------- |
| n    | `gd`         | Go to definition       |
| n    | `gi`         | Go to implementation   |
| n    | `gr`         | Find references/finder |
| n    | `<leader>K`  | Hover docs             |
| n    | `<leader>ca` | Code action            |
| n    | `<leader>cd` | Line diagnostics       |
| n    | `cr`         | Rename                 |

## Diagnostics list

| Mode | Key          | Action         |
| ---- | ------------ | -------------- |
| n    | `<leader>xx` | Toggle Trouble |

## Running code

| Mode | Key | Action                                             |
| ---- | --- | -------------------------------------------------- |
| n    | `R` | Run current Python file in a bottom terminal split |

## Markdown

| Mode                | Key              | Action                                  |
| ------------------- | ---------------- | --------------------------------------- |
| n (markdown buffer) | `<localleader>t` | Open in Typora + apply Rectangle layout |

## Jtext

| Mode | Key              | Action                                          |
| ---- | ---------------- | ----------------------------------------------- |
| n    | `<localleader>s` | Save + sync current `.py` via `~/scripts/jtext` |

## Mason

| Mode | Key         | Action        |
| ---- | ----------- | ------------- |
| n    | `<leader>m` | Open Mason UI |

## Debugging (DAP)

> Note: DAP mappings use **localleader** (`,`).

| Mode | Key                                   | Action                                |
| ---- | ------------------------------------- | ------------------------------------- |
| n    | `<localleader>df`                     | Debug current Python file (launch)    |
| n    | `<localleader>db`                     | Toggle breakpoint (●)                 |
| n    | `<localleader>dB`                     | Conditional breakpoint (◆)            |
| n    | `<localleader>dd` / `<localleader>dc` | Start/continue                        |
| n    | `<localleader>dj` / `<localleader>dn` | Step over                             |
| n    | `<localleader>dk` / `<localleader>di` | Step into                             |
| n    | `<localleader>dl` / `<localleader>do` | Step out                              |
| n    | `<localleader>dq`                     | Terminate session                     |
| n    | `<localleader>dC`                     | Clear all breakpoints                 |
| n    | `<localleader>dr`                     | Toggle REPL                           |
| n    | `<localleader>de`                     | Break on exceptions (raised/uncaught) |
| n    | `<localleader>du`                     | Toggle DAP UI                         |
| n    | `<localleader>dU`                     | Open DAP UI (reset layout)            |
| n    | `<localleader>dp`                     | Breakpoints (float)                   |
| n    | `<localleader>dw`                     | Watches (float)                       |
| n    | `<localleader>ds`                     | Stacks (float)                        |

### DAP UI panels (what to look at)

- **Scopes**: local variables/args (primary)
- **Stacks**: call stack / current frame
- **Console**: program output + exceptions
