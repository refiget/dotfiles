# Neovim Configuration

This is a comprehensive Neovim configuration with numerous enhancements over the default setup.

## Table of Contents

- [Changes Compared to Default](#changes-compared-to-default)
- [Python Dependencies](#python-dependencies)
- [Plugin Management](#plugin-management)
- [Key Mappings](#key-mappings)
- [Installation](#installation)

## Changes Compared to Default

### Core Settings

| Setting | Value | Description |
|---------|-------|-------------|
| `undolevels` | 10000 | Increased undo levels for better history |
| `breakindent` | true | Preserve indentation on wrapped lines |
| `linebreak` | true | Break lines at word boundaries |
| `undoreload` | 10000 | Increased undo reload limit |
| `swapfile` | false | Disable swap files |
| `laststatus` | 2 | Always show status line |
| `exrc` | true | Allow local .nvimrc files |
| `secure` | true | Secure mode for local configs |
| `number` | true | Show line numbers |
| `relativenumber` | true | Show relative line numbers |
| `cursorline` | true | Highlight current line |
| `expandtab` | false | Use tabs instead of spaces |
| `tabstop` | 2 | Tab width of 2 spaces |
| `shiftwidth` | 2 | Indent width of 2 spaces |
| `softtabstop` | 2 | Soft tab width of 2 spaces |
| `autoindent` | true | Auto indent new lines |
| `list` | true | Show invisible characters |
| `listchars` | `tab = "| ", trail = "▫"` | Visual representation of tabs and trailing spaces |
| `scrolloff` | 4 | Keep 4 lines of context around cursor |
| `ttimeoutlen` | 0 | No timeout for key sequences |
| `timeout` | false | Disable timeout for mapped keys |
| `viewoptions` | `["cursor", "folds", "slash", "unix"]` | Persist cursor position and folds |
| `wrap` | true | Wrap long lines |
| `foldmethod` | "indent" | Fold based on indentation |
| `foldlevel` | 99 | Start with all folds open |
| `splitbelow` | true | Split horizontally below current window |
| `splitright` | true | Split vertically to the right of current window |
| `ignorecase` | true | Case-insensitive search |
| `smartcase` | true | Case-sensitive search when using uppercase |
| `completeopt` | `["menuone", "noselect"]` | Better completion options |
| `updatetime` | 100 | Faster updates for LSP and git signs |
| `virtualedit` | "block" | Allow virtual editing in block mode |
| `inccommand` | "split" | Show live preview of substitutions |
| `showmode` | false | Hide mode indicator (handled by status line) |
| `lazyredraw` | true | Improve performance by lazy redrawing |
| `visualbell` | true | Use visual bell instead of audio |
| `colorcolumn` | "100" | Show color column at 100 characters |
| `re` | 0 | Use old regex engine for better performance |

### Directories

- `backupdir`: `~/.config/nvim/tmp/backup,.` - Custom backup directory
- `directory`: `~/.config/nvim/tmp/backup,.` - Custom swap directory
- `undodir`: `~/.config/nvim/tmp/undo,.` - Custom undo directory
- `undofile`: true - Enable persistent undo

## Python Dependencies

### Required Python Packages

The configuration uses a Python virtual environment for Neovim. The following steps will set up the required Python dependencies:

1. **Create a Python virtual environment** (recommended):
   ```bash
   # Option 1: Using ~/venvs/nvim
   mkdir -p ~/venvs
   python3 -m venv ~/venvs/nvim
   
   # Option 2: Using ~/.venvs/nvim
   mkdir -p ~/.venvs
   python3 -m venv ~/.venvs/nvim
   ```

2. **Activate the virtual environment and install dependencies**:
   ```bash
   # For ~/venvs/nvim
   source ~/venvs/nvim/bin/activate
   
   # For ~/.venvs/nvim
   source ~/.venvs/nvim/bin/activate
   
   # Install required packages
   pip install --upgrade pip
   pip install pynvim
   ```

### Python Host Detection

The configuration automatically detects the Python host in the following order:
1. `~/venvs/nvim/bin/python3`
2. `~/.venvs/nvim/bin/python3`
3. `/usr/local/opt/python@3/bin/python3`
4. `/opt/homebrew/bin/python3`
5. `/usr/local/bin/python3`
6. `/usr/bin/python3`

## Plugin Management

The configuration uses `lazy.nvim` for plugin management. Here's a list of installed plugins:

### Core Plugins

- `neovim/nvim-lspconfig` - LSP configuration
- `hrsh7th/nvim-cmp` - Completion engine
- `hrsh7th/cmp-nvim-lsp` - LSP completion source
- `hrsh7th/cmp-buffer` - Buffer completion source
- `hrsh7th/cmp-path` - Path completion source
- `hrsh7th/cmp-cmdline` - Command line completion source
- `L3MON4D3/LuaSnip` - Snippet engine
- `saadparwaiz1/cmp_luasnip` - Snippet completion source

### Syntax and Highlighting

- `nvim-treesitter/nvim-treesitter` - Syntax highlighting and parsing
- `HiPhish/rainbow-delimiters.nvim` - Rainbow parentheses
- `RRethy/vim-illuminate` - Highlight word under cursor

### Appearance

- `theniceboy/nvim-deus` - Color scheme
- `petertriho/nvim-scrollbar` - Enhanced scrollbar
- `theniceboy/eleline.vim` - Status line
- `NvChad/nvim-colorizer.lua` - Color preview
- `kevinhwang91/nvim-hlslens` - Enhanced search highlighting
- `akinsho/bufferline.nvim` - Tabline
- `lewis6991/gitsigns.nvim` - Git status in sign column
- `nvim-tree/nvim-web-devicons` - File icons

### Navigation

- `nvim-telescope/telescope.nvim` - Fuzzy finder
- `nvim-lua/plenary.nvim` - Utility functions

### Editing Helpers

- `windwp/nvim-autopairs` - Auto close pairs
- `echasnovski/mini.surround` - Surround text manipulation
- `junegunn/vim-after-object` - Enhanced text objects
- `lukas-reineke/indent-blankline.nvim` - Indentation guides
- `Vimjas/vim-python-pep8-indent` - Python indentation

### Markdown

- `iamcco/markdown-preview.nvim` - Markdown preview in browser

## Key Mappings

### Basic Mappings

- `;` - Enter command mode
- `Q` - Quit current window
- `Y` - Copy line to system clipboard
- `<leader><CR>` - Clear search highlight

### Navigation

- `J` - Move down 5 lines
- `K` - Move up 5 lines
- `<leader>l` - Move to right window
- `<leader>k` - Move to upper window
- `<leader>j` - Move to lower window
- `<leader>h` - Move to left window

### File Explorer

- `<leader>e` - Open file explorer (Telescope)

### Markdown

- `<leader>mp` - Start Markdown preview
- `<leader>mP` - Stop Markdown preview

### Tabs

- `gt` - Next tab (with wrap)
- `gT` - Previous tab (with wrap)

### LSP

- `<leader>f` - Format document
- `cr` - Rename symbol
- `gd` - Go to definition
- `gi` - Go to implementation
- `gr` - Go to references
- `K` - Show hover information

### Python

- `r` - Run Python file

### Terminal

- `<C-N>` - Enter normal mode in terminal

### Delete Behavior

- `d`/`D` - Normal delete (writes to default register)
- `x`/`X` - Delete character without affecting registers (writes to black hole register)
- `c`/`C` - Change text without affecting registers (writes to black hole register)

### Projects and Dotfiles Search

- `<leader>w` - Search files in Projects + dotfiles (opens in new tab)

## Installation

1. **Clone the dotfiles repository**:
   ```bash
   git clone <repository-url> ~/dotfiles
   ```

2. **Run the deploy script**:
   ```bash
   cd ~/dotfiles
   ./deploy.sh
   ```

3. **Set up Python dependencies** (as described above)

4. **Open Neovim to install plugins**:
   ```bash
   nvim
   ```

   The `lazy.nvim` plugin manager will automatically install all required plugins on first run.

5. **Install LSP servers**:
   ```bash
   # Install pyright for Python
   npm install -g pyright
   ```

6. **Optional: Install im-select for macOS IME switching**:
   ```bash
   brew install im-select
   ```

## Additional Features

- **Automatic plugin installation** - Plugins are installed automatically on first run
- **LSP dependency checking** - Warns if required LSP dependencies are missing
- **Treesitter** - Enhanced syntax highlighting for various languages
- **Clipboard integration** - Works with system clipboard and tmux
- **macOS IME switching** - Automatically switches IME between insert and normal modes
- **Tmux integration** - Synchronizes mode between Neovim and tmux
- **Snippets** - Predefined snippets for Python and Markdown
