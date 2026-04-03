# zsh

This directory contains the zsh configuration.

- Loader: `~/dotfiles/.zshrc` → deployed to `~/.zshrc`
- Modules: `conf.d/*.conf`

## Layout rules

- `.zshrc` is a thin loader only
- `01_*` = shell basics that must load first
- `02_*` = PATH / environment wiring
- `10_*` = framework / prompt
- `20_*` = aliases and command ergonomics
- `30_*` = tool integrations and shell helpers
- `40_*` = UI / keybindings / hooks / behavior fixes
- `50_*` = language-specific helpers
- `80_*` = local overrides
- `90_*` = checks and autostart
- prefer keeping tool-specific setup out of the loader
- prefer `path=( ... $path )` over repeated raw `export PATH=...:$PATH`

For an overview, see the repo-level **README-zsh.md**.

## Current structure

- `10_framework_zim.conf` → Zim framework init
- `11_prompt.conf` → Pure prompt styling
- `20_aliases_core.conf` → safe/default aliases
- `21_aliases_workflow.conf` → personal workflow shortcuts
- `30_openclaw.conf` → OpenClaw completion
- `31_fastfetch.conf` → fastfetch placeholder/customization
- `32_sgpt_alias.conf` → shell_gpt shortcuts
- `33_tools_navigation.conf` → yazi / zoxide / fzf
- `34_tools_runtime.conf` → lazy nvm
- `35_tools_history.conf` → atuin
- `40_keybindings.conf` → vi mode and readline-style bindings
- `50_python_venv.conf` → Python virtualenv helpers
- `80_local_overrides.conf` → machine-local overrides
- `90_dep_checks.conf` → soft startup checks
- `95_autostart_tmux.conf` → optional tmux auto-entry
