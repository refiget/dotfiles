# zsh Configuration

This is a comprehensive zsh configuration with numerous enhancements over the default setup.

## Table of Contents

- [Changes Compared to Default](#changes-compared-to-default)
- [Key Features](#key-features)
- [Installation](#installation)

## Changes Compared to Default

### Shell Options

| Option | Value | Description |
|--------|-------|-------------|
| `PROMPT_SUBST` | enabled | Enable prompt substitution for dynamic updates |
| `HIST_IGNORE_ALL_DUPS` | enabled | Ignore duplicate history entries |
| `HIST_IGNORE_SPACE` | enabled | Ignore commands starting with space |
| `HIST_REDUCE_BLANKS` | enabled | Remove unnecessary blanks from history |
| `HIST_VERIFY` | enabled | Verify history expansions before execution |
| `CORRECT` | enabled | Enable command correction |
| `AUTO_CD` | enabled | Automatically cd to directories without typing cd |
| `INTERACTIVE_COMMENTS` | enabled | Allow comments in interactive shells |

### History Settings

| Setting | Value | Description |
|---------|-------|-------------|
| `HISTSIZE` | 5000 | Number of history entries kept in memory |
| `SAVEHIST` | 5000 | Number of history entries saved to file |
| `HISTFILE` | `~/.zsh_history` | Path to history file |

### Environment Variables

| Variable | Value | Description |
|----------|-------|-------------|
| `EDITOR` | `nvim` | Default editor |
| `VISUAL` | `nvim` | Visual editor |
| `PAGER` | `less` | Default pager |

### PATH Configuration

The PATH is configured with the following directories (in order):

1. `$HOME/.local/bin`
2. `/usr/local/bin`
3. `/usr/bin`
4. `/bin`
5. `/usr/sbin`
6. `/sbin`
7. Existing PATH entries

### OS-Specific Settings

#### macOS
- Loads Homebrew shell environment

#### Linux
- Adds `/usr/local/sbin:/usr/local/bin` to PATH for pacman-based systems

## Key Features

### Modular Configuration

The configuration is split into multiple files for better organization:

- `01_env_path.conf` - Environment variables and PATH setup
- `02_framework_zim.conf` - Zim framework configuration
- `03_prompt.conf` - Prompt configuration
- `04_alias.conf` - Aliases
- `05_tools.conf` - Tool configurations
- `06_keybindings.conf` - Key bindings
- `07_tmux_sync.conf` - Tmux synchronization
- `08_local_overrides.conf` - Local overrides
- `09_dep_checks.conf` - Dependency checks
- `10_autostart_tmux.conf` - Tmux autostart

### Virtual Environment Support

- Displays current virtual environment in prompt
- Supports both Conda and virtualenv environments

### Zim Framework

Uses the Zim framework for enhanced zsh functionality with:

- Modules for various zsh enhancements
- Efficient plugin loading

### Aliases

Custom aliases for common commands (details in `04_alias.conf`)

### Key Bindings

Enhanced key bindings for better shell navigation and interaction (details in `06_keybindings.conf`)

### Tmux Integration

- Automatic tmux session management
- Synchronization between zsh and tmux

### Dependency Checks

Automatic checks for required dependencies (details in `09_dep_checks.conf`)

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

3. **Install Zim framework** (if not already installed):
   ```bash
   # Install Zim
   curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
   ```

4. **Restart zsh**:
   ```bash
   exec zsh
   ```

5. **Optional: Install dependencies**:
   ```bash
   # For macOS
   brew install <required-packages>
   
   # For Linux
   sudo pacman -S <required-packages>
   ```

## Additional Information

### Local Overrides

You can add local overrides in `08_local_overrides.conf` without modifying the main configuration files.

### Prompt Customization

The prompt includes:
- Current working directory
- Git branch status
- Virtual environment information
- Return code of last command

### Autostart Tmux

The configuration can automatically start tmux when opening a terminal (configured in `10_autostart_tmux.conf`)
