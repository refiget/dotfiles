#!/usr/bin/env bash

# Cross-platform (macOS/Linux) dotfiles deploy script
# Works with Bash 3.2+ (macOS) and Bash 5+ (Linux)

# ==========================================
# 配置区域
# ==========================================
# 脚本所在目录即 dotfiles 根；避免依赖当前工作目录
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

mkdir -p "$CONFIG_DIR"
mkdir -p "$BACKUP_DIR"
mkdir -p "$HOME/.jupyter"

# ==========================================
# 核心函数: 兼容 Bash 3.2 (macOS) 和 Bash 5+ (Linux)
# ==========================================
link_file() {
    local SRC=$1
    local DEST=$2
    local FILENAME=$(basename "$SRC")

    # 1. 检查源文件是否存在
    if [ ! -e "$SRC" ]; then
        echo "⚠️  源缺失 (跳过): $FILENAME"
        return
    fi

    # 2. 检查是否已经是正确的软连接
    if [ -L "$DEST" ]; then
        local CURRENT_LINK=$(readlink "$DEST")
        if [ "$CURRENT_LINK" == "$SRC" ]; then
            echo "✅ 已连接 (跳过): $FILENAME"
            return
        fi
    fi

    # 3. 如果目标存在，则备份或强制覆盖
    if [ -e "$DEST" ] || [ -L "$DEST" ]; then
        if [[ "$FORCE_SYNC" -eq 1 ]]; then
            echo "♻️  覆盖已存在的目标（force sync）: $DEST"
            rm -rf "$DEST"
        else
            local TS
            TS=$(date +%s)
            echo "🔄 备份冲突: $DEST -> $BACKUP_DIR/${FILENAME}_${TS}"
            mv "$DEST" "$BACKUP_DIR/${FILENAME}_${TS}"
        fi
    fi

    # 4. 建立连接
    echo "🔗 建立连接: $FILENAME -> $DEST"
    ln -s "$SRC" "$DEST" || echo "⚠️  链接失败，请检查权限或路径: $SRC -> $DEST"
}

# ==========================================
# 执行逻辑
# ==========================================
echo "🚀 开始部署 Dotfiles (Universal Version)..."
echo "📂 源目录: $DOTFILES_DIR"
echo "---------------------------------------------"

# --- 根目录文件 ---
link_file "$DOTFILES_DIR/.zshrc"      "$HOME/.zshrc"
link_file "$DOTFILES_DIR/.zprofile"   "$HOME/.zprofile"
link_file "$DOTFILES_DIR/.zimrc"      "$HOME/.zimrc"
link_file "$DOTFILES_DIR/.tmux.conf"  "$HOME/.tmux.conf"
link_file "$DOTFILES_DIR/.gitconfig"  "$HOME/.gitconfig"
link_file "$DOTFILES_DIR/.ignore"     "$HOME/.ignore"

# --- .config 目录下的文件夹 ---
link_file "$DOTFILES_DIR/nvim"          "$CONFIG_DIR/nvim"
link_file "$DOTFILES_DIR/tmux"          "$CONFIG_DIR/tmux"
link_file "$DOTFILES_DIR/yazi"          "$CONFIG_DIR/yazi"
link_file "$DOTFILES_DIR/fastfetch"     "$CONFIG_DIR/fastfetch"
link_file "$DOTFILES_DIR/iterm2"        "$CONFIG_DIR/iterm2"
link_file "$DOTFILES_DIR/borders"       "$CONFIG_DIR/borders"
# yabai config directory path
link_file "$DOTFILES_DIR/yabai"         "$CONFIG_DIR/yabai"

# qutebrowser: use Bob's default path (~/.qutebrowser)
link_file "$DOTFILES_DIR/qutebrowser"   "$HOME/.qutebrowser"
link_file "$DOTFILES_DIR/sketchybar"    "$CONFIG_DIR/sketchybar"

# Jupyter default config path is ~/.jupyter
link_file "$DOTFILES_DIR/jupyter/jupyter.json" "$HOME/.jupyter/jupyter.json"
link_file "$DOTFILES_DIR/kitty"         "$CONFIG_DIR/kitty"
link_file "$DOTFILES_DIR/starship/starship-tmux.toml" "$CONFIG_DIR/starship-tmux.toml"
link_file "$DOTFILES_DIR/starship/starship-tmux-inactive.toml" "$CONFIG_DIR/starship-tmux-inactive.toml"
link_file "$DOTFILES_DIR/scripts"       "$HOME/scripts"

# qutebrowser compatibility bridge:
# Some launch methods read ~/.qutebrowser, others use XDG (~/.config/qutebrowser).
# Keep both paths consistent by linking ~/.config/qutebrowser -> ~/.qutebrowser.
if [ -e "$CONFIG_DIR/qutebrowser" ] || [ -L "$CONFIG_DIR/qutebrowser" ]; then
    if [ -L "$CONFIG_DIR/qutebrowser" ] && [ "$(readlink "$CONFIG_DIR/qutebrowser")" = "$HOME/.qutebrowser" ]; then
        echo "✅ qutebrowser XDG 兼容链接已就绪"
    else
        if [[ "$FORCE_SYNC" -eq 1 ]]; then
            echo "♻️  覆盖 qutebrowser XDG 路径（force sync）: $CONFIG_DIR/qutebrowser"
            rm -rf "$CONFIG_DIR/qutebrowser"
            ln -s "$HOME/.qutebrowser" "$CONFIG_DIR/qutebrowser"
        else
            TS=$(date +%s)
            echo "🔄 备份 qutebrowser XDG 路径: $CONFIG_DIR/qutebrowser -> $BACKUP_DIR/qutebrowser_${TS}"
            mv "$CONFIG_DIR/qutebrowser" "$BACKUP_DIR/qutebrowser_${TS}"
            ln -s "$HOME/.qutebrowser" "$CONFIG_DIR/qutebrowser"
        fi
    fi
else
    ln -s "$HOME/.qutebrowser" "$CONFIG_DIR/qutebrowser"
    echo "🔗 建立 qutebrowser XDG 兼容链接: $CONFIG_DIR/qutebrowser -> $HOME/.qutebrowser"
fi

# Legacy paths cleanup hints (non-destructive):
if [ -e "$HOME/.yabairc" ] || [ -L "$HOME/.yabairc" ]; then
    echo "ℹ️  检测到旧路径 $HOME/.yabairc（当前方案使用 $CONFIG_DIR/yabai）"
fi
if [ -e "$CONFIG_DIR/jupyter" ] || [ -L "$CONFIG_DIR/jupyter" ]; then
    echo "ℹ️  检测到旧路径 $CONFIG_DIR/jupyter（Jupyter 默认读取 ~/.jupyter）"
fi

# --- LazyGit（只修改这里）-----------------------------------
# Linux 使用 ~/.config/lazygit
# macOS 使用 ~/Library/Application Support/lazygit

# 1. 删除 macOS 默认路径（避免冲突）
if [[ "$OS_NAME" == "Darwin" ]]; then
    MACOS_LG_DIR="$HOME/Library/Application Support/lazygit"
    if [ -e "$MACOS_LG_DIR" ] || [ -L "$MACOS_LG_DIR" ]; then
        echo "🧼 移除 macOS LazyGit 默认目录 (避免配置冲突): $MACOS_LG_DIR"
        rm -rf "$MACOS_LG_DIR"
    fi
fi

# 2. 链接 ~/.config/lazygit
link_file "$DOTFILES_DIR/lazygit" "$CONFIG_DIR/lazygit"

# 3. macOS 再补充一个链接（LazyGit 的实际读取目录）
if [[ "$OS_NAME" == "Darwin" ]]; then
    MACOS_LG_DIR="$HOME/Library/Application Support/lazygit"
    mkdir -p "$MACOS_LG_DIR"

    echo "🔗 macOS LazyGit 软链接 (config.yml) → dotfiles"
    ln -sf "$DOTFILES_DIR/lazygit/config.yml" "$MACOS_LG_DIR/config.yml"
fi
# ---------------------------------------------------------------

echo "---------------------------------------------"
echo "🎉 部署完成！"

if [[ "$AUTO_LAZY" -eq 1 ]]; then
    if command -v nvim >/dev/null 2>&1; then
        echo "⬇️  自动拉取 Neovim 插件 (lazy.nvim)..."
        nvim --headless "+Lazy sync" +qa || echo "⚠️  lazy.nvim 拉取失败，请手动运行: nvim --headless \"+Lazy sync\" +qa"
    else
        echo "⚠️  未找到 nvim，跳过 lazy.nvim 插件拉取。"
    fi
fi
