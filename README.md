# Dotfiles

This repository contains my personal dotfiles configuration for Neovim, tmux, and zsh. It provides a comprehensive setup with numerous enhancements over the default configurations.

## Table of Contents

- [Overview](#overview)
- [Components](#components)
- [Installation](#installation)
- [Directory Structure](#directory-structure)
- [Usage](#usage)

## Overview

This dotfiles repository includes:

- **Neovim** configuration with plugins, key mappings, and enhanced settings
- **tmux** configuration with session management, clipboard integration, and theme support
- **zsh** configuration with history enhancements, aliases, and prompt customization

All configurations are designed to work together seamlessly, providing a consistent and efficient development environment.

## Components

### Neovim

A feature-rich Neovim configuration with:

- **Plugin Management**: Uses `lazy.nvim` for efficient plugin loading
- **LSP Integration**: Built-in support for Language Server Protocol
- **Completion**: Enhanced code completion with `nvim-cmp`
- **Syntax Highlighting**: Improved syntax highlighting with Treesitter
- **Navigation**: Fuzzy file finding with Telescope
- **Appearance**: Custom theme and status line
- **Python Integration**: Project-local virtualenv auto-detection (`./.venv`, `./venv`, `./.env`) for Pyright + Python-specific features

For detailed information, see [README-nvim.md](README-nvim.md).

### tmux

A comprehensive tmux configuration with:

- **Session Management**: Enhanced session creation and switching
- **Clipboard Integration**: Seamless integration with system clipboard (copy/paste scripts strip trailing newlines to avoid accidental Enter)
- **Copy Mode**: Vi-style copy-mode bindings (manual `q/Q` to exit copy-mode)
- **Pane Navigation**: Easy navigation between panes
- **Theme Support**: Dynamic theming that integrates with Neovim
- **Mouse Support**: Full mouse support for easier interaction
- **Scripting**: Utility scripts for common tasks

Note: A previous scratchpad window feature has been removed; no scratchpad keybindings are configured.

For detailed information, see [README-tmux.md](README-tmux.md).

### zsh

An enhanced zsh configuration with:

- **History Management**: Improved history handling and search
- **Prompt Customization**: Informative prompt with git and virtual environment support
- **Aliases**: Useful aliases for common commands
- **Zim Framework**: Efficient plugin loading with Zim
- **Tmux Integration**: Automatic tmux session management
- **OS Detection**: OS-specific settings for macOS and Linux

For detailed information, see [README-zsh.md](README-zsh.md).

## Installation

### Prerequisites

- **Git**: For cloning the repository
- **Neovim**: Version 0.8.0 or later
- **tmux**: Version 3.0 or later
- **zsh**: Version 5.0 or later
- **Python 3**: For Neovim Python integration
- **Node.js**: For LSP servers and certain plugins

Optional but recommended:
- **black / flake8**: Python formatter/linter used by the Neovim checks (install in your project venv or globally)

### Installation Steps

1. **Clone the repository**:
   ```bash
   git clone <repository-url> ~/dotfiles
   ```

2. **Run the deploy script**:
   ```bash
   cd ~/dotfiles
   ./deploy.sh
   ```

3. **Set up Python dependencies**:
   ```bash
   # Create a virtual environment for Neovim
   python3 -m venv ~/venvs/nvim
   
   # Activate and install dependencies
   source ~/venvs/nvim/bin/activate
   pip install --upgrade pip
   pip install pynvim
   ```

4. **Install Zim framework** (for zsh):
   ```bash
   curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
   ```

5. **Install LSP servers**:
   ```bash
   # Python LSP (Pyright)
   npm install -g pyright
   
   # Optional Python tools (install in project venv recommended)
   # python -m pip install -U black flake8
   ```

6. **Open Neovim to install plugins**:
   ```bash
   nvim
   ```

   The `lazy.nvim` plugin manager will automatically install all required plugins on first run.

7. **Optional: Install additional dependencies**:
   ```bash
   # For macOS
   brew install im-select fzf
   
   # For Linux
   sudo pacman -S <required-packages>
   ```

## Directory Structure

```
dotfiles/
├── .gitconfig          # Git configuration
├── .gitignore          # Git ignore patterns
├── .ignore             # Global ignore patterns
├── .tmux.conf          # tmux configuration loader
├── .zimrc              # Zim framework configuration
├── .zprofile           # Zsh profile
├── .zshrc              # Zsh configuration loader

├── deploy.sh           # Deployment script
├── iterm2/             # iTerm2 configuration
├── jupyter/            # Jupyter configuration
├── lazygit/            # LazyGit configuration
├── nvim/               # Neovim configuration
├── README-nvim.md      # Neovim documentation
├── README-tmux.md      # tmux documentation
├── README-zsh.md       # zsh documentation
├── scripts/            # Utility scripts
├── tmux/               # tmux configuration files
├── yazi/               # Yazi file manager configuration
└── zsh/                # zsh configuration files
```

## Usage

### Neovim

- Launch Neovim with `nvim`
- Use `<leader>e` to open file explorer
- Use `<leader>f` to format document with LSP
- Use `r` to run Python files
- Use `gt`/`gT` to navigate tabs

For more key mappings and features, see [README-nvim.md](README-nvim.md).

### tmux

- Launch tmux with `tmux`
- Use prefix + `r` to reload configuration
- Use mouse to navigate between panes and windows
- Use session management scripts for easier session handling

For more key mappings and features, see [README-tmux.md](README-tmux.md).

### zsh

- Launch zsh with `zsh`
- Use arrow keys to navigate history
- Use `Ctrl+R` to search history
- Use aliases for common commands
- Enjoy the informative prompt with git and virtual environment status

For more features and configuration options, see [README-zsh.md](README-zsh.md).

## Customization

### Local Overrides

You can add local overrides without modifying the main configuration files:

- **zsh**: Add overrides to `zsh/conf.d/08_local_overrides.conf`
- **Neovim**: Add custom plugins and settings to the appropriate files in `nvim/lua/user/`
- **tmux**: Add custom settings to a new file in `tmux/conf.d/`

### Theme Customization

The color scheme is primarily defined in the Neovim configuration, with tmux automatically syncing its colors. To change the theme:

1. Modify the Neovim color scheme in `nvim/lua/user/plugins.lua`
2. Update tmux theme colors in the appropriate tmux configuration files

## Troubleshooting

### Common Issues

1. **Python dependencies not found**:
   - Ensure you've created and activated the Python virtual environment
   - Verify `python3_host_prog` is set correctly in Neovim

2. **Plugins not installing**:
   - Ensure you have an internet connection
   - Check Neovim error messages for specific issues

3. **Tmux not starting**:
   - Check tmux configuration for syntax errors
   - Ensure required dependencies are installed

4. **Zsh prompt not showing correctly**:
   - Ensure Zim framework is installed
   - Check for syntax errors in zsh configuration files

### Debugging

- **Neovim**: Run `nvim --headless -c 'echo $MYVIMRC' -c 'q'` to check configuration path
- **tmux**: Run `tmux show-options -g` to see current settings
- **zsh**: Run `zsh -x` to see verbose output of shell initialization

## Contributing

Feel free to fork this repository and make changes. Pull requests are welcome for improvements and bug fixes.

## License

This repository is licensed under the MIT License. See the LICENSE file for details.



