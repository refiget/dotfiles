#!/usr/bin/env bash

# Cross-platform (macOS/Linux) dotfiles deploy script
# Compatible with Bash 3.2+ (macOS default) and newer Bash on Linux

set -u

# ==========================================
# 基础路径与参数
# ==========================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$SCRIPT_DIR"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"
OS_NAME="$(uname -s)"
FORCE_SYNC=0
AUTO_LAZY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--force|--sync)
      FORCE_SYNC=1
      shift
      ;;
    --lazy)
      AUTO_LAZY=1
      shift
      ;;
    *)
      echo "未知参数: $1"
      exit 1
      ;;
  esac
done

mkdir -p "$CONFIG_DIR" "$BACKUP_DIR" "$HOME/.jupyter"

# ==========================================
# 日志工具
# ==========================================
section() {
  echo
  echo "== $1 =="
}

info() {
  echo "ℹ️  $1"
}

# ==========================================
# 链接工具
# ==========================================
backup_or_remove_dest() {
  local DEST="$1"
  local NAME="$2"

  if [[ "$FORCE_SYNC" -eq 1 ]]; then
    echo "♻️  覆盖已存在的目标（force sync）: $DEST"
    rm -rf "$DEST"
  else
    local TS
    TS="$(date +%s)"
    echo "🔄 备份冲突: $DEST -> $BACKUP_DIR/${NAME}_${TS}"
    mv "$DEST" "$BACKUP_DIR/${NAME}_${TS}"
  fi
}

link_file() {
  local SRC="$1"
  local DEST="$2"
  local NAME
  NAME="$(basename "$SRC")"

  if [[ ! -e "$SRC" ]]; then
    echo "⚠️  源缺失 (跳过): $NAME"
    return
  fi

  mkdir -p "$(dirname "$DEST")"

  if [[ -L "$DEST" ]]; then
    local CURRENT_LINK
    CURRENT_LINK="$(readlink "$DEST")"
    if [[ "$CURRENT_LINK" == "$SRC" ]]; then
      echo "✅ 已连接 (跳过): $NAME"
      return
    fi
  fi

  if [[ -e "$DEST" || -L "$DEST" ]]; then
    backup_or_remove_dest "$DEST" "$NAME"
  fi

  echo "🔗 建立连接: $NAME -> $DEST"
  ln -s "$SRC" "$DEST" || echo "⚠️  链接失败，请检查权限或路径: $SRC -> $DEST"
}

link_pairs() {
  local PAIRS=("$@")
  local i
  for ((i=0; i<${#PAIRS[@]}; i+=2)); do
    link_file "${PAIRS[i]}" "${PAIRS[i+1]}"
  done
}

# ==========================================
# 特殊兼容逻辑
# ==========================================
link_qutebrowser_bridge() {
  local XDG_DEST="$CONFIG_DIR/qutebrowser"
  local HOME_DEST="$HOME/.qutebrowser"

  if [[ -e "$XDG_DEST" || -L "$XDG_DEST" ]]; then
    if [[ -L "$XDG_DEST" && "$(readlink "$XDG_DEST")" == "$HOME_DEST" ]]; then
      echo "✅ qutebrowser XDG 兼容链接已就绪"
    else
      backup_or_remove_dest "$XDG_DEST" "qutebrowser"
      ln -s "$HOME_DEST" "$XDG_DEST"
      echo "🔗 建立 qutebrowser XDG 兼容链接: $XDG_DEST -> $HOME_DEST"
    fi
  else
    ln -s "$HOME_DEST" "$XDG_DEST"
    echo "🔗 建立 qutebrowser XDG 兼容链接: $XDG_DEST -> $HOME_DEST"
  fi
}

link_ghostty_macos() {
  [[ "$OS_NAME" == "Darwin" ]] || return

  local GHOSTTY_MAC_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
  mkdir -p "$GHOSTTY_MAC_DIR"
  link_file "$DOTFILES_DIR/ghostty/config" "$GHOSTTY_MAC_DIR/config.ghostty"
}

setup_lazygit() {
  link_file "$DOTFILES_DIR/lazygit" "$CONFIG_DIR/lazygit"

  [[ "$OS_NAME" == "Darwin" ]] || return

  local MACOS_LG_DIR="$HOME/Library/Application Support/lazygit"
  if [[ -e "$MACOS_LG_DIR" || -L "$MACOS_LG_DIR" ]]; then
    echo "🧼 移除 macOS LazyGit 默认目录 (避免配置冲突): $MACOS_LG_DIR"
    rm -rf "$MACOS_LG_DIR"
  fi

  mkdir -p "$MACOS_LG_DIR"
  echo "🔗 macOS LazyGit 软链接 (config.yml) → dotfiles"
  ln -sf "$DOTFILES_DIR/lazygit/config.yml" "$MACOS_LG_DIR/config.yml"
}

print_legacy_hints() {
  if [[ -e "$HOME/.yabairc" || -L "$HOME/.yabairc" ]]; then
    info "检测到旧路径 $HOME/.yabairc（当前方案使用 $CONFIG_DIR/yabai）"
  fi

  if [[ -e "$CONFIG_DIR/jupyter" || -L "$CONFIG_DIR/jupyter" ]]; then
    info "检测到旧路径 $CONFIG_DIR/jupyter（Jupyter 默认读取 ~/.jupyter）"
  fi
}

maybe_sync_lazy() {
  [[ "$AUTO_LAZY" -eq 1 ]] || return

  if command -v nvim >/dev/null 2>&1; then
    echo "⬇️  自动拉取 Neovim 插件 (lazy.nvim)..."
    nvim --headless "+Lazy sync" +qa || echo "⚠️  lazy.nvim 拉取失败，请手动运行: nvim --headless \"+Lazy sync\" +qa"
  else
    echo "⚠️  未找到 nvim，跳过 lazy.nvim 插件拉取。"
  fi
}

# ==========================================
# 链接清单
# ==========================================
ROOT_LINKS=(
  "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
  "$DOTFILES_DIR/.zprofile" "$HOME/.zprofile"
  "$DOTFILES_DIR/.zimrc" "$HOME/.zimrc"
  "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"
  "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
  "$DOTFILES_DIR/.ignore" "$HOME/.ignore"
  "$DOTFILES_DIR/.ideavimrc" "$HOME/.ideavimrc"
  "$DOTFILES_DIR/.shellfishrc" "$HOME/.shellfishrc"
)

CONFIG_LINKS=(
  "$DOTFILES_DIR/nvim" "$CONFIG_DIR/nvim"
  "$DOTFILES_DIR/doom" "$CONFIG_DIR/doom"
  "$DOTFILES_DIR/tmux" "$CONFIG_DIR/tmux"
  "$DOTFILES_DIR/yazi" "$CONFIG_DIR/yazi"
  "$DOTFILES_DIR/fastfetch" "$CONFIG_DIR/fastfetch"
  "$DOTFILES_DIR/iterm2" "$CONFIG_DIR/iterm2"
  "$DOTFILES_DIR/borders" "$CONFIG_DIR/borders"
  "$DOTFILES_DIR/yabai" "$CONFIG_DIR/yabai"
  "$DOTFILES_DIR/sketchybar" "$CONFIG_DIR/sketchybar"
  "$DOTFILES_DIR/karabiner" "$CONFIG_DIR/karabiner"
  "$DOTFILES_DIR/kitty" "$CONFIG_DIR/kitty"
  "$DOTFILES_DIR/alacritty" "$CONFIG_DIR/alacritty"
  "$DOTFILES_DIR/ghostty" "$CONFIG_DIR/ghostty"
  "$DOTFILES_DIR/starship/starship-tmux.toml" "$CONFIG_DIR/starship-tmux.toml"
  "$DOTFILES_DIR/starship/starship-tmux-inactive.toml" "$CONFIG_DIR/starship-tmux-inactive.toml"
)

HOME_LINKS=(
  "$DOTFILES_DIR/qutebrowser" "$HOME/.qutebrowser"
  "$DOTFILES_DIR/hammerspoon" "$HOME/.hammerspoon"
  "$DOTFILES_DIR/scripts" "$HOME/scripts"
  "$DOTFILES_DIR/jupyter/jupyter.json" "$HOME/.jupyter/jupyter.json"
)

# ==========================================
# 执行
# ==========================================
echo "🚀 开始部署 Dotfiles (Universal Version)..."
echo "📂 源目录: $DOTFILES_DIR"
echo "---------------------------------------------"

section "根目录配置"
link_pairs "${ROOT_LINKS[@]}"

section ".config 与家目录配置"
link_pairs "${CONFIG_LINKS[@]}"
link_pairs "${HOME_LINKS[@]}"

section "兼容桥接"
link_qutebrowser_bridge
link_ghostty_macos
setup_lazygit
print_legacy_hints

echo "---------------------------------------------"
echo "🎉 部署完成！"

maybe_sync_lazy
