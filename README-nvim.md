# Neovim

Neovim config focused on LSP-first editing, fast navigation, and minimal friction for Python.

## Highlights

- LSP setup with sensible defaults
- Python: **project venv auto-detection** for Pyright
  - searches `./.venv`, `./venv`, `./.env`, or `$VIRTUAL_ENV`
  - pushes settings to the LSP server on init (more reliable than only `on_new_config`)
- Diagnostics: use built-in navigation (`]d`, `[d`) and lists (`:lopen`)

## Files

- Config dir: `~/dotfiles/nvim/`
- Deployed to: `~/.config/nvim` (via `deploy.sh`)

Key implementation points live in:

- `~/.config/nvim/lua/config/lsp.lua`

## Install / bootstrap

1) Deploy symlinks:

```bash
cd ~/dotfiles
./deploy.sh
```

2) Ensure Neovim Python host is available (one-time):

```bash
python3 -m venv ~/venvs/nvim
~/venvs/nvim/bin/pip install -U pip pynvim
```

3) LSP tools (example):

```bash
npm i -g pyright
```

## Tips

- If imports are unresolved in Python:
  - confirm the project venv exists (`.venv` recommended)
  - restart LSP (`:LspRestart`) after creating venv

## Source of truth

READMEs stay intentionally high-level. For exact behavior:

- inspect Lua: `~/.config/nvim/lua/`
- inspect mappings: `:map`, `:nmap`, `:imap`
