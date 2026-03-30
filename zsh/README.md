# zsh

This directory contains the zsh configuration.

- Loader: `~/dotfiles/.zshrc` → deployed to `~/.zshrc`
- Modules: `conf.d/*.conf`

## Layout rules

- `.zshrc` is a thin loader only
- `01_*` = shell basics that must load first
- `02_*` = PATH / environment wiring
- later modules = framework, prompt, tools, aliases, UX hooks, local overrides
- prefer keeping tool-specific setup out of the loader
- prefer `path=( ... $path )` over repeated raw `export PATH=...:$PATH`

For an overview, see the repo-level **README-zsh.md**.
