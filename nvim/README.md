# Neovim 使用说明（插件与快捷键）

## 启动与依赖
- 首次启动：自动检查并安装缺失的 coc.nvim、coc-pyright、telescope.nvim、plenary.nvim（触发 `:PlugInstall --sync`）。
- 系统依赖提示：缺 node/npm/python3 会弹提示（需要手动安装：Arch pacman / macOS brew）。
- Python host：自动探测 `~/.venvs/nvim/bin/python3`、Homebrew、系统路径。

## 补全 / LSP
- coc.nvim + coc-pyright：Python 补全/诊断，重命名 `cr`，格式化 `<leader>f`。
- 片段：LuaSnip（Tab/Shift-Tab 跳转），自动加载用户 snippets 与 friendly-snippets。

## DeepSeek 集成
- 问答：`<leader>dq` 输入问题，右侧终端显示回答。
- 代码审阅：可视选区 `<leader>dr`。
- doctest 生成：`<leader>dt` 读取当前 buffer，清理 ANSI/Markdown，自动找到首个以冒号结尾的代码块后一行插入，按作用域缩进并包裹三重引号。
- 路径：使用 `~/Projects/deepseek-cli` 及其中的 `ds`，需确保存在可执行文件。

## 查找 / 导航
- Telescope 文件查找：`<leader>w`（Projects + dotfiles），Enter 在新 tab 打开，`<C-v>/<C-x>` 分屏（i/n 模式一致）。
- 标签：`gt/gT` 循环切换，支持数字前缀。

## 窗口 / 运行
- 快速运行 Python：普通模式 `r`，保存并在分屏终端执行当前文件。
- 分屏导航：`<leader>h/j/k/l`。
- 基础行跳：`J/K` 跳 5 行。

## Markdown / 辅助
- 包含 render-markdown、indent-blankline、colorizer、scrollbar、rainbow-delimiters 等 UI 辅助插件。
- 切换 wrap：`<leader>sw`。
- 终端模式退出：`<C-N>`。

## Coc 相关按键
- 重命名：`cr`
- 格式化：`<leader>f`
- 插入模式回车：自动确认补全 `coc#_select_confirm()`；否则正常回车。

## Buffer / Tabs
- bufferline: 显示标签行，诊断来源 coc；常规 `:bnext/:bprev` 可用，标签循环用 `gt/gT`。

## 示例（doctest 生成）
```
# 在 Python 文件中按 <leader>dt
"""
>>> foo(1, 2)
3
"""
```
