# 模块化 zsh 配置加载器
__zshrc_path="${${(%):-%N}:A}"
DOTFILES_DIR="${DOTFILES_DIR:-${__zshrc_path:h}}"
ZSH_CONF_DIR="${ZSH_CONF_DIR:-$DOTFILES_DIR/zsh/conf.d}"

if [[ -d "$ZSH_CONF_DIR" ]]; then
  # 1) 先加载核心环境（必须先于其它模块）
  if [[ -f "$ZSH_CONF_DIR/01_env_path.conf" ]]; then
    source "$ZSH_CONF_DIR/01_env_path.conf"
  fi

  # 2) 非交互 shell 到此为止，避免加载 zim/fzf/tmux 等副作用模块
  [[ -o interactive ]] || return

  # 2.5) Compile the *actual* loader file for faster startups (avoid assuming ~/.zshrc)
  if [[ -n "$__zshrc_path" ]]; then
    local zwc="${__zshrc_path}.zwc"
    if [[ ! -f "$zwc" || "$__zshrc_path" -nt "$zwc" ]]; then
      zcompile "$__zshrc_path" 2>/dev/null
    fi
  fi

  # 3) 再加载其余模块（跳过已加载的 01_env_path.conf）
  setopt local_options null_glob
  for conf_file in "$ZSH_CONF_DIR"/*.conf; do
    [[ "$conf_file" == "$ZSH_CONF_DIR/01_env_path.conf" ]] && continue
    [[ -f "$conf_file" ]] && source "$conf_file"
  done
else
  echo "警告：未找到 zsh 模块目录 $ZSH_CONF_DIR"
fi


# OpenClaw Completion
source "/Users/bob/.openclaw/completions/openclaw.zsh"
