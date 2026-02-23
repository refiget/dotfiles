# Modular zsh loader
__zshrc_path="${${(%):-%N}:A}"
DOTFILES_DIR="${DOTFILES_DIR:-${__zshrc_path:h}}"
ZSH_CONF_DIR="${ZSH_CONF_DIR:-$DOTFILES_DIR/zsh/conf.d}"

if [[ ! -d "$ZSH_CONF_DIR" ]]; then
  echo "警告：未找到 zsh 模块目录 $ZSH_CONF_DIR"
  return
fi

# 1) Core env must load first
[[ -f "$ZSH_CONF_DIR/01_env_path.conf" ]] && source "$ZSH_CONF_DIR/01_env_path.conf"

# 2) Non-interactive shells stop here
[[ -o interactive ]] || return

# 3) Compile current loader for faster startups
if [[ -n "$__zshrc_path" ]]; then
  local zwc="${__zshrc_path}.zwc"
  if [[ ! -f "$zwc" || "$__zshrc_path" -nt "$zwc" ]]; then
    zcompile "$__zshrc_path" 2>/dev/null
  fi
fi

# 4) Load remaining modules
setopt local_options null_glob
for conf_file in "$ZSH_CONF_DIR"/*.conf; do
  [[ "$conf_file" == "$ZSH_CONF_DIR/01_env_path.conf" ]] && continue
  source "$conf_file"
done
