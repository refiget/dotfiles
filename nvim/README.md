# Neovim 配置说明

## 配置结构

```
dotfiles/nvim/
├── init.lua                 # 主入口文件
├── lua/
│   └── user/
│       ├── config/          # 配置模块
│       │   ├── env.lua      # 环境配置
│       │   ├── options.lua  # 选项配置
│       │   └── autocmds.lua # 自动命令
│       ├── plugins/         # 插件配置
│       ├── keymaps.lua      # 按键映射
│       ├── snippets.lua     # 代码片段
│       ├── clipboard.lua    # 剪贴板配置
│       ├── tmux.lua         # tmux 集成
│       └── ime.lua          # 输入法切换
└── README.md                # 配置文档
```

## 默认设置更改

### 编辑器选项
- `undolevels = 10000` - 增加撤销级别
- `breakindent = true` - 启用换行缩进
- `linebreak = true` - 启用行换行
- `undoreload = 10000` - 增加撤销重载
- `swapfile = false` - 禁用交换文件
- `laststatus = 2` - 始终显示状态栏
- `exrc = true` - 启用本地配置文件
- `secure = true` - 安全模式
- `number = true` - 显示行号
- `relativenumber = true` - 显示相对行号
- `cursorline = true` - 高亮当前行
- `expandtab = false` - 不使用空格替代制表符
- `tabstop = 2` - 制表符宽度
- `shiftwidth = 2` - 缩进宽度
- `softtabstop = 2` - 软制表符宽度
- `autoindent = true` - 自动缩进
- `list = true` - 显示不可见字符
- `listchars = { tab = "| ", trail = "▫" }` - 不可见字符显示
- `scrolloff = 4` - 滚动时保持光标周围的行数
- `ttimeoutlen = 0` - 按键超时时间
- `timeout = false` - 禁用超时
- `viewoptions = { "cursor", "folds", "slash", "unix" }` - 视图选项
- `wrap = true` - 启用换行
- `foldmethod = "indent"` - 折叠方法
- `foldlevel = 99` - 折叠级别
- `splitbelow = true` - 水平分割在下方
- `splitright = true` - 垂直分割在右侧
- `ignorecase = true` - 搜索忽略大小写
- `smartcase = true` - 智能大小写搜索
- `completeopt = { "menuone", "noselect" }` - 补全选项
- `updatetime = 100` - 更新时间
- `virtualedit = "block"` - 虚拟编辑模式
- `inccommand = "split"` - 增量命令
- `showmode = false` - 不显示模式
- `lazyredraw = true` - 延迟重绘
- `visualbell = true` - 视觉铃声
- `colorcolumn = "100"` - 颜色列位置
- `re = 0` - 正则表达式引擎

### 备份和缓存
- `backupdir = fn.expand("$HOME/.config/nvim/tmp/backup,.")` - 备份目录
- `directory = fn.expand("$HOME/.config/nvim/tmp/backup,.")` - 交换文件目录
- `undodir = fn.expand("$HOME/.config/nvim/tmp/undo,.")` - 撤销目录
- `undofile = true` - 启用撤销文件

## 额外设置

### 环境配置
- 设置 `PYTHONWARNINGS = "ignore::SyntaxWarning"` - 忽略 Python 语法警告
- 自动检测 Python 解释器，优先使用虚拟环境中的 Python

### 自动命令
- 读取文件后跳转到上次编辑的位置
- 打开终端时自动进入插入模式
- Markdown 文件自动启用拼写检查

### 插件配置
- **LSP / 补全**：nvim-lspconfig、nvim-cmp、cmp-nvim-lsp、cmp-buffer、cmp-path、cmp-cmdline、LuaSnip、cmp_luasnip
- **语法高亮**：nvim-treesitter
- **外观**：nvim-deus（主题）、nvim-scrollbar、rainbow-delimiters.nvim、eleline.vim、vim-illuminate、nvim-colorizer.lua、nvim-hlslens、bufferline.nvim、gitsigns.nvim
- **文件浏览器**：telescope.nvim
- **编辑辅助**：nvim-autopairs、mini.surround、vim-after-object、indent-blankline.nvim、vim-python-pep8-indent
- **Markdown 预览**：markdown-preview.nvim

## 按键绑定

### 基础按键
- `;` - 进入命令模式
- `Q` - 关闭当前窗口
- `Y` - 复制当前行到系统剪贴板
- `<leader><CR>` - 清除搜索高亮

### 高级按键
- `J` - 向下移动 5 行
- `K` - 向上移动 5 行

### 窗口管理
- `<leader>l` - 移动到右侧窗口
- `<leader>k` - 移动到上方窗口
- `<leader>j` - 移动到下方窗口
- `<leader>h` - 移动到左侧窗口

### 文件浏览器
- `<leader>e` - 打开文件浏览器（使用 telescope）

### Markdown 预览
- `<leader>mp` - 启动 Markdown 预览
- `<leader>mP` - 停止 Markdown 预览

### 标签页管理
- `gt` - 下一个标签页（循环）
- `gT` - 上一个标签页（循环）

### LSP 功能
- `<leader>f` - 格式化文档
- `cr` - 重命名符号
- `gd` - 跳转到定义
- `gi` - 跳转到实现
- `gr` - 跳转到引用
- `K` - 显示悬停信息

### 终端
- `<C-N>` - 从终端模式退出到普通模式

### 删除行为
- `d` / `D` - 正常删除（写入默认寄存器）
- `x` / `X` - 删除一个字符（写入黑洞寄存器）
- `c` / `C` - 修改文本（写入黑洞寄存器）

### Telescope 搜索
- `<leader>w` - 在 Projects 和 dotfiles 目录中搜索文件

## Python 依赖安装

### 虚拟环境设置

1. **创建虚拟环境**：
   ```bash
   mkdir -p ~/venvs
   python3 -m venv ~/venvs/nvim
   ```

2. **激活虚拟环境**：
   ```bash
   source ~/venvs/nvim/bin/activate
   ```

3. **安装所需包**：
   ```bash
   pip install --upgrade pip
   pip install pynvim
   pip install black
   pip install flake8
   pip install pyright
   ```

### 所需的 Python 包

- **pynvim**：Neovim 的 Python 客户端
- **black**：Python 代码格式化工具
- **flake8**：Python 代码检查工具
- **pyright**：Python 静态类型检查器

## 插件安装

1. **启动 Neovim**：
   ```bash
   nvim
   ```

2. **安装插件**：
   ```vim
   :Lazy sync
   ```

3. **配置 LSP**：
   插件安装完成后，LSP 会自动配置。

## 故障排除

### 常见问题

1. **Python 依赖问题**：
   - 确保虚拟环境已正确创建
   - 确保所有必要的 Python 包已安装

2. **插件加载失败**：
   - 运行 `:Lazy check` 检查插件状态
   - 运行 `:Lazy install` 安装缺失的插件

3. **LSP 服务器未启动**：
   - 确保 pyright 已安装
   - 检查 Python 解释器配置

### 调试命令

- `:Lazy` - 打开插件管理器
- `:LspInfo` - 显示 LSP 服务器状态
- `:checkhealth` - 检查 Neovim 健康状态
