# tmux Configuration

This is a comprehensive tmux configuration with numerous enhancements over the default setup.

## Table of Contents

- [Changes Compared to Default](#changes-compared-to-default)
- [Key Mappings](#key-mappings)
- [Features](#features)
- [Installation](#installation)

## Changes Compared to Default

### General Settings

| Setting | Value | Description |
|---------|-------|-------------|
| `xterm-keys` | on | Enable xterm-style function keys |
| `escape-time` | 0 | No delay for escape sequences |
| `repeat-time` | 300 | Time between key repeats |
| `focus-events` | on | Enable focus events |
| `extended-keys` | on | Enable extended key support |
| `set-clipboard` | on | Enable clipboard support |
| `allow-passthrough` | on | Enable passthrough for certain keys |
| `mouse` | on | Enable mouse support |
| `exit-empty` | on | Exit session when last window is closed |
| `detach-on-destroy` | off | Don't detach when destroying last session |
| `status-utf8` | on | Enable UTF-8 in status line |
| `utf8` | on | Enable UTF-8 support |
| `visual-activity` | off | Disable visual activity alerts |
| `monitor-activity` | off | Disable activity monitoring |
| `monitor-bell` | off | Disable bell monitoring |
| `history-limit` | 10000 | Increased history limit |

### Environment Variables

The configuration updates the following environment variables:

- `DISPLAY`
- `DBUS_SESSION_BUS_ADDRESS`
- `QT_IM_MODULE`
- `QT_QPA_PLATFORMTHEME`
- `SESSION_MANAGER`
- `XDG_CONFIG_HOME`
- `XDG_CACHE_HOME`
- `XDG_DATA_HOME`
- `XDG_MENU_PREFIX`
- `XDG_RUNTIME_DIR`
- `XDG_SESSION_CLASS`
- `XDG_SESSION_DESKTOP`
- `XDG_SESSION_TYPE`
- `XDG_CURRENT_DESKTOP`
- `XMODIFIERS`
- `FZF_DEFAULT_OPTS`
- `TMUX_THEME_COLOR`

## Key Mappings

### Basic Mappings

- `r` (prefix + r) - Reload tmux configuration

### Navigation

- Enhanced pane navigation with keyboard shortcuts
- Mouse support for pane and window selection

### Clipboard

- Integrated clipboard support with system clipboard
- Copy mode enhancements

### Session Management

- Session switching utilities
- Session creation and management scripts

## Features

### Modular Configuration

The configuration is split into multiple files for better organization:

- `01_general.conf` - General settings
- `02_hooks.conf` - Tmux hooks
- `03_prefix_display.conf` - Prefix key display
- `04_navigation.conf` - Navigation settings
- `05_clipboard.conf` - Clipboard configuration
- `06_pane_navigation.conf` - Pane navigation
- `07_copy_mode.conf` - Copy mode settings
- `08_toggle_theme.conf` - Theme toggling
- `09_session_switch.conf` - Session switching
- `10_terminal.conf` - Terminal settings

### Scripts

The configuration includes several utility scripts:

- `check_and_run_on_activate.sh` - Run commands on session activation
- `copy_to_clipboard.sh` - Copy to system clipboard
- `layout_builder.sh` - Build custom layouts
- `move_session.sh` - Move sessions between servers
- `move_window_to_session.sh` - Move windows between sessions
- `new_session.sh` - Create new sessions
- `pane_starship_title.sh` - Set pane titles with starship
- `paste_from_clipboard.sh` - Paste from system clipboard
- `rename_session_prompt.sh` - Rename sessions with prompt
- `session_created.sh` - Run on session creation
- `session_manager.py` - Python-based session manager
- `switch_session_by_index.sh` - Switch sessions by index
- `toggle_orientation.sh` - Toggle pane orientation
- `toggle_scratchpad.sh` - Toggle scratchpad window
- `update_theme_color.sh` - Update theme colors

### Status Bar

Custom status bar with:

- Left status components
- Right status components
- Dynamic theming

### Theme Support

- Theme toggling capabilities
- Color coordination with Neovim

### FZF Integration

- FZF-based pane navigation
- Enhanced session management

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

3. **Start tmux**:
   ```bash
   tmux
   ```

4. **Optional: Install dependencies**:
   ```bash
   # For clipboard support
   # macOS
   brew install reattach-to-user-namespace
   
   # For FZF integration
   brew install fzf
   
   # For Python scripts
   pip install -r <path-to-requirements>
   ```

## Additional Information

### Session Management

The configuration includes a Python-based session manager (`session_manager.py`) that provides enhanced session management capabilities.

### Theme Integration

The tmux theme is designed to integrate with the Neovim color scheme, providing a consistent visual experience across both tools.

### Clipboard Integration

The configuration provides seamless clipboard integration between tmux and the system clipboard, making it easy to copy and paste between tmux sessions and other applications.

### Pane Management

Enhanced pane management with keyboard shortcuts and mouse support makes it easy to navigate and organize tmux panes.

### Scratchpad Support

A scratchpad window can be toggled on and off for quick access to frequently used tools or information.
