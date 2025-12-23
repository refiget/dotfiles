# 模块化 zsh 配置加载器（内容与参考版一致，放在 zsh/conf.d/00_main.conf）
__zshrc_path="${${(%):-%N}:A}"
DOTFILES_DIR="${DOTFILES_DIR:-${__zshrc_path:h}}"
ZSH_CONF_DIR="${ZSH_CONF_DIR:-$DOTFILES_DIR/zsh/conf.d}"

if [[ -d "$ZSH_CONF_DIR" ]]; then
  for conf_file in "$ZSH_CONF_DIR"/*.conf; do
    [[ -f "$conf_file" ]] && source "$conf_file"
  done
else
  echo "警告：未找到 zsh 模块目录 $ZSH_CONF_DIR"
fi

