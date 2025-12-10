# Dotfiles README (Neovim + Zsh) - Quick Usage

## 概览
- Neovim: 以 coc.nvim 为核心补全，配合 Telescope/treesitter/LuaSnip。DeepSeek CLI 集成提供问答/代码审阅/doctest 生成。
- Zsh (Zim): 提供补全、fzf-tab、自动提示、语法高亮；别名与路径按 macOS/Arch 区分。
- Tmux/窗口管理: skhd + yabai（非注入）用于窗口焦点/重排，tmux 支持 fzf 会话切换。

## Neovim
- 启动与依赖：首次启动自动 PlugInstall 缺失的 coc.nvim/coc-pyright/telescope/plenary；若缺 node/npm/python3 会给提示（需手动安装）。
- DeepSeek
  - 问答: `<leader>dq` 输入问题，右侧终端输出
  - 代码审阅: 选中代码，`<leader>dr`
  - doctest 生成: `<leader>dt` 读取当前 buffer，清理 ANSI/Markdown，插入到首个冒号行之后，按缩进包裹三重引号
- 标签/查找
  - 标签循环: `gt/gT` 支持循环和数字前缀
  - Telescope 文件查找: `<leader>w`，Enter 在新 tab 打开（i/n 模式一致），`<C-v>/<C-x>` 分屏
- 代码片段: LuaSnip，Tab/Shift-Tab 跳转；自动加载用户 snippets + friendly-snippets
- 运行 Python: 普通模式按 `r`，当前文件在分屏终端运行

示例：在 Python 文件里生成 doctest
```
# 将光标置于任意位置，或直接执行
<leader>dt
# 插入结果（示例）
"""
>>> foo(1, 2)
3
"""
```

## Zsh (Zim)
- 模块: completion, git/git-info, zsh-completions, zsh-autosuggestions, fzf-tab, fast-syntax-highlighting
- 依赖提示: 缺 node/npm/python3/fzf 会在 shell 启动时提示（按平台给出安装建议）
- 常用别名: `ls/ll/la`，`o`(open/xdg-open)，`update`(pacman 或 apt)，`reload` 重新加载 zshrc
- NVM 懒加载: 首次调用 node/npm/nvm 时再加载
- 路径: 自动加载 Homebrew（macOS），合并 /usr/local /opt/homebrew

示例：使用 fzf-tab 补全
- 输入 `git checkout <Tab>`，会出现 fzf 风格的分支列表供选择。

## Tmux / 窗口管理
- tmux: Prefix C-q (macOS) / C-e (Linux)，支持 fzf 会话切换（缺 fzf 会提示并降级）。
- skhd + yabai: Alt+h/j/k/l 焦点，Alt+Shift+h/j/k/l 交换/warp，Alt+b 平铺，Alt+c 浮动切换，Alt+m 最大化。
- 重启服务: `scripts/restart_yabai_skhd.sh`（macOS，launchctl 优先，brew services 兜底）。

示例：tmux fzf 切换会话
- 按 `s` 弹出 fzf 列表，回车切换；缺 fzf 时会提示安装。


