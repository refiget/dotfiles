# ~/dotfiles/.zshenv
# Universal environment for all zsh invocations (GUI apps, IDE, terminal, scripts)

# dotfiles location
export DOTFILES_DIR="$HOME/dotfiles"
export ZSH_CONF_DIR="$DOTFILES_DIR/zsh/conf.d"

# Locale
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Stable base PATH (GUI + shell consistency)
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "/opt/homebrew/bin"
  "/opt/homebrew/sbin"
  "/usr/local/bin"
  "/usr/local/sbin"
  "/usr/bin"
  "/bin"
  "/usr/sbin"
  "/sbin"
  $path
)
export PATH

# Rust toolchain
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
